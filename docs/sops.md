# Secrets with sops + sops-nix

How secrets work in this repo, how to edit them, and how to bring up a new machine without
the old "create key → deploy → update sops → rebuild again" dance.

## How it works (the 2-minute version)

Each file in `secrets/` is encrypted with a random **data key**. That data key is then
encrypted separately to every **recipient** (an age public key) allowed to read the file. Anyone
holding *one* of the matching private keys can decrypt the data key, and therefore the file.

There are three kinds of recipient:

| Kind | Private key lives | Used by | When |
|---|---|---|---|
| **YubiKeys** ×3 | in the YubiKey's PIV applet, never leaves it | you, running `sops` | everyday edit / rekey, on **any** machine |
| **Host keys** | `/etc/ssh/ssh_host_ed25519_key` on each machine (root-only) | sops-nix at boot | decrypting into `/run/secrets/` |
| **Break-glass** | 1Password only | you, via `sops-breakglass` | all YubiKeys lost / unavailable |

YubiKeys and break-glass are **admins**: they can read every file. A host can only read
`secrets/common.yaml` and its own `secrets/<hostname>.yaml`.

```
                 secrets/common.yaml          secrets/<host>.yaml
admins           ✓                            ✓
john-laptop      ✓                            john-laptop.yaml only
minecraft-server ✓                            minecraft-server.yaml only
```

### Files

| Path | What |
|---|---|
| `secrets/keys.nix` | **Source of truth** for recipients (admins + hosts). Edit this, not `.sops.yaml`. |
| `.sops.yaml` | Generated from `keys.nix` by `nix run .#sops-config`. |
| `secrets/yubikey-identities.txt` | YubiKey identity *stubs*: serial + slot + public tag. Not secret, safe in git. |
| `secrets/common.yaml` | Secrets every host gets (e.g. `john-password`). |
| `secrets/<host>.yaml` | Secrets only that host gets (e.g. `minecraft-server.yaml`). |
| `hosts/common/core/sops.nix` | Shared sops-nix wiring, imported by every host. |
| `scripts/sops-tools.nix` | `sops-config`, `sops-new-host`, `sops-host`, `sops-breakglass`. |

On every host built from this flake, `SOPS_AGE_KEY_FILE` points at the identity stubs, and the
helper commands are on `PATH`. The custom live USB has the same setup built in. Anywhere else (a borrowed machine), run `nix develop` in
the repo, which sets `SOPS_AGE_KEY_FILE` for you, and use `nix run .#<tool>` for the helpers.

## Everyday use

### Edit a secrets file

```bash
sops secrets/common.yaml
```

Plug in any of the three YubiKeys. You'll be asked for the **PIV PIN** once per login session,
and the key blinks for a touch (the touch is cached for 15 s). The Nano lives in john-laptop, so
there it's just PIN + touch.

> The PIV PIN (6–8 chars) is separate from the 4-digit FIDO2 PIN used for login/sudo. Three
> wrong PIV PINs block it; unblock with `ykman piv access unblock-pin` + the PUK. Both are in
> 1Password.

No YubiKey to hand?

```bash
sops-host secrets/common.yaml          # uses this machine's host key via sudo
sops-breakglass secrets/common.yaml    # uses the 1Password key (prompts for 1Password unlock)
```

`sops-host` can only open files this host is a recipient of. `sops-breakglass` reads
`op://Private/NixOS - SOPs Break Glass John age key/age key` by default. Set `SOPS_BREAKGLASS_OP_REF` if you stored
it elsewhere.

### Add a secret and use it in NixOS

1. Add the value: `sops secrets/common.yaml` (or `secrets/<host>.yaml` for host-only).
   Nest keys if you like:
   ```yaml
   wifi:
     home-psk: hunter2
   ```
2. Declare it in the host config:
   ```nix
   sops.secrets."wifi/home-psk" = {};                     # from common.yaml (the default)
   sops.secrets.restic-password = {
     sopsFile = ../../secrets/john-laptop.yaml;           # host-only file
     owner = "john";                                      # default is root:root 0400
   };
   ```
3. Point the service at the decrypted file, never at the value:
   ```nix
   services.foo.passwordFile = config.sops.secrets."wifi/home-psk".path;  # /run/secrets/wifi/home-psk
   ```
4. `git add` any new files (flakes ignore untracked files), then rebuild.

To give a host its own file for the first time, just run `sops secrets/<host>.yaml`. The
creation rule for it already exists as long as the host is in `keys.nix`.

### Secrets for home-manager

**Recommended: decrypt at system level, give the user ownership, and have home-manager
reference the path.** Root decrypts at boot with the host key, and `john` can read the result. No
user-level key is needed, and nothing needs the host key to be readable by `john`.

```nix
# hosts/<host>/default.nix (NixOS side)
sops.secrets.git-identity = {
  owner = "john";
  # sopsFile = ../../secrets/<host>.yaml;   # if it should be host-only
};
```

```nix
# home/john/<host>.nix (home-manager side, running as a NixOS module)
{osConfig, ...}: {
  # A file in git-config format, included at runtime:
  programs.git.includes = [{path = osConfig.sops.secrets.git-identity.path;}];

  # Or an env var / token read at shell start:
  programs.zsh.initContent = ''
    export SOME_TOKEN="$(cat ${osConfig.sops.secrets.some-token.path})"
  '';
}
```

Here `git-identity` in `common.yaml` would be a multi-line value:

```yaml
git-identity: |
  [user]
    name = ...
    email = ...
```

Rules of thumb:
- Reference the **path**, and let the program read it at runtime. Never read the secret's
  value into Nix (`builtins.readFile` etc.), because that copies the plaintext into the
  world-readable `/nix/store`.
- If you need it in a file of your own, use `sops.templates."name".content` on the NixOS side
  with `config.sops.placeholder.<secret>`, and set `owner = "john"`.
- `osConfig` only exists when home-manager runs as a NixOS module (as it does in this flake).
  If you omit `path`/`owner`, the file ends up at `/run/secrets/<name>`.

*Not recommended:* the home-manager sops module (`sops = { ... }` inside a home config). It
decrypts as `john` at login, so it needs a private key that `john` can read. That was the old
`setfacl` on the host key, and it means any process running as you can steal the host's
identity. It's still loaded in `flake.nix` if you ever genuinely need it with a dedicated user
age key.

## Bringing up a new machine

The trick is to **create the host's SSH key before installing**. Its age recipient is added and
the secrets are re-encrypted, and only then is the key placed on the new disk. The first boot can
then decrypt everything, so there's no second round.

`sops-new-host <host>` does the key part:

1. generates `etc/ssh/ssh_host_ed25519_key` in a temp dir (or reuses one already there),
2. adds `<host> = "age1…";` to `secrets/keys.nix` and regenerates `.sops.yaml`,
3. runs `sops updatekeys` on `common.yaml` (and `<host>.yaml` if present). **YubiKey touch.**
4. `git add`s the changes and prints the next command.

Before you start, create `hosts/<host>/` and its `nixosConfigurations.<host>` entry as usual, and
make sure `networking.hostName` matches the name you give `sops-new-host`.

### A) nixos-anywhere (from john-laptop)

```bash
cd ~/.config/nixos-config
sops-new-host my-new-host
#   -> Host key is in: /tmp/sops-new-host-my-new-host.XXXXXX/etc/ssh/

nixos-anywhere \
  --extra-files /tmp/sops-new-host-my-new-host.XXXXXX \
  --generate-hardware-config nixos-generate-config ./hosts/my-new-host/hardware-configuration.nix \
  --flake .#my-new-host root@<ip>

git add -A hosts/my-new-host && git commit -m "feat: add my-new-host"
```

`--extra-files` copies the directory tree onto the new root, so the key lands at
`/etc/ssh/ssh_host_ed25519_key`. sshd uses it instead of generating a new one, and sops-nix
decrypts with it at the first activation.

Afterwards: optionally save the private key to 1Password (so a reinstall keeps the same
identity, and you can re-run `sops-new-host --out <dir>` with it to skip rekeying), then
`rm -rf` the temp dir.

### B) Manual install from the live USB

Partition and mount at `/mnt` as usual (e.g. `disko`). Then pick one:

**B1: generate the key on john-laptop and copy it over** (works with any ISO):

```bash
# on john-laptop
sops-new-host my-new-host
scp -r /tmp/sops-new-host-my-new-host.XXXXXX/etc/ssh nixos@<live-usb-ip>:/tmp/hostkey

# on the live USB
sudo mkdir -p /mnt/etc/ssh
sudo cp /tmp/hostkey/ssh_host_ed25519_key* /mnt/etc/ssh/
sudo chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key
```

**B2: do everything on the live USB with a YubiKey plugged into it.** The custom ISO
(`nixos-iso/`) ships everything for this: `pcscd`, `age-plugin-yubikey`, `ykman`, `op`,
`SOPS_AGE_KEY_FILE` and the `sops-*` helpers. (If the ISO is older than this setup, rebuild and
re-burn it: `cd nixos-iso && nix build .#iso`. You also need to rebuild it after adding or
replacing a YubiKey, because it bakes in `secrets/yubikey-identities.txt`.)

```bash
# the repo is private: authenticate first (device-code flow works fine on the live USB)
gh auth login
gh repo clone johnnyfleet/nixos-config && cd nixos-config

sops-new-host my-new-host --out /tmp/hostkey     # as the normal user, not root; YubiKey PIN + touch
sudo mkdir -p /mnt/etc/ssh && sudo cp -a /tmp/hostkey/etc/ssh/ssh_host_ed25519_key* /mnt/etc/ssh/
sudo chown root:root /mnt/etc/ssh/ssh_host_ed25519_key*
git commit -m "feat: add my-new-host sops recipient" && git push   # or later, from the new machine
```

Quick check that the YubiKey is visible before you start: `age-plugin-yubikey --list`.

Then install as usual:

```bash
sudo nixos-install --flake .#my-new-host
```

`nixos-install` runs the activation inside `/mnt`, so sops-nix finds `/mnt/etc/ssh/…` and
`neededForUsers` secrets (like `john-password`) work on the very first boot.

### Test machines and VMs

- **Only need to *edit* secrets there?** Don't register anything. Plug in a YubiKey and run
  `nix develop`. Done.
- **A VM that shouldn't touch secrets:** don't declare any `sops.secrets` (see
  `minecraftServer.testVm` for the pattern: real secrets behind `lib.mkIf (!testVm)`, local
  stand-ins otherwise).
- **A throwaway host that needs real secrets:** `sops-new-host test-thing`, then remove it from
  `keys.nix` again afterwards (see below).

If a host declares secrets but isn't in `keys.nix`, the build prints a warning telling you to
run `sops-new-host`.

### Rehearsing an install in a VM

`nixosConfigurations.john-laptop-test` is john-laptop's software on a QEMU VM (disko disk, qemu
guest hardware, hostname `john-laptop-test`, Kindo S3 off because its secrets are host-only).
Use it to run the full nixos-anywhere + `sops-new-host` flow without touching real hardware.
It is a *separate identity*: it reads `common.yaml`, not `john-laptop.yaml`.

**1. Build the live ISO** (needs to include the YubiKey/sops bits, so rebuild if it predates them):

```bash
cd ~/.config/nixos-config/nixos-iso && nix build .#iso
ls result/iso/my-nixos-live.iso
```

**2. Create and boot the VM from the ISO** (UEFI, because john-laptop uses systemd-boot):

```bash
mkdir -p ~/vms/john-laptop-test && cd ~/vms/john-laptop-test
qemu-img create -f qcow2 disk.qcow2 80G          # john-laptop's closure is big
OVMF=$(nix build --no-link --print-out-paths nixpkgs#OVMF.fd)
cp "$OVMF/FV/OVMF_VARS.fd" vars.fd && chmod u+w vars.fd

vm() {   # vm [extra qemu args...]
  qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -smp 4 -m 8G \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF/FV/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file=vars.fd \
    -drive file=disk.qcow2,if=virtio,format=qcow2 \
    -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:2222-:22 \
    -vga virtio -display gtk "$@"
}
vm -cdrom ~/.config/nixos-config/nixos-iso/result/iso/my-nixos-live.iso
```

Once it has booted, check you can get in as root (the ISO trusts your GitHub SSH keys). The ISO
gets a fresh host key every boot, so skip known_hosts for it:

```bash
ssh -p 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost hostname
#   -> my-nixos-live
```

**3. Pre-generate the host key and register it** (on john-laptop; YubiKey PIN + touch):

```bash
cd ~/.config/nixos-config
sops-new-host john-laptop-test            # or: nix run .#sops-new-host -- john-laptop-test
#   john-laptop-test -> age1...
#   Host key is in: /tmp/sops-new-host-john-laptop-test.XXXXXX/etc/ssh/
```

The `john-laptop-test` warning from the build goes away now. Don't commit these changes if this
is a throwaway test (see step 6).

**4. Install with nixos-anywhere:**

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#john-laptop-test \
  --target-host root@localhost -p 2222 \
  --extra-files /tmp/sops-new-host-john-laptop-test.XXXXXX \
  --phases disko,install
```

- `--phases disko,install` skips `kexec` (the ISO is already a NixOS installer) and `reboot`
  (QEMU would just boot the ISO again).
- It builds locally and copies the whole closure over SSH. Expect many GB and some minutes.
- The sops-nix activation during install already runs with the injected key. If the key is
  wrong, you'll see `sops-install-secrets` errors in this output.

**5. Boot the installed system and check the secrets:**

```bash
ssh -p 2222 -o UserKnownHostsFile=/dev/null root@localhost poweroff
vm                                        # same VM, no -cdrom this time

ssh-keygen -R "[localhost]:2222"          # the host now has the pre-generated key
ssh -p 2222 john@localhost
```

On the VM:

```bash
hostname                                          # john-laptop-test
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub   # same age1... as secrets/keys.nix
sudo ls -l /run/secrets-for-users/john-password   # decrypted on first boot, no second rebuild
journalctl -b | grep -i sops                      # no "failed to decrypt"
```

Optional extras:
- **Later deploys still decrypt:**
  `NIX_SSHOPTS="-p 2222" nixos-rebuild switch --flake .#john-laptop-test --target-host john@localhost --sudo`
- **YubiKey inside the VM:** add `-device qemu-xhci -device usb-host,vendorid=0x1050,productid=0x0407`
  to `vm`. QEMU needs access to the USB device, and the key disappears from the host while the
  VM holds it. Then clone the repo in the VM and run `sops secrets/common.yaml`.

**6. Clean up**, so the test key doesn't stay a recipient:

```bash
# stop the VM, then delete it and the host key material
rm -rf ~/vms/john-laptop-test /tmp/sops-new-host-john-laptop-test.*

# not committed: put the secrets back exactly as they were
cd ~/.config/nixos-config
git restore --staged --worktree secrets/keys.nix .sops.yaml secrets/common.yaml
```

If you *did* commit or push the registration, remove `john-laptop-test` from `keys.nix` and
follow [Removing a host](#removing-a-host-or-a-loststolen-yubikey) (`updatekeys` + `rotate`).
After a restore no rotation is needed, as long as the test key only ever existed in the
deleted VM and temp dir.

### Adding an existing machine (key already on it)

```bash
ssh-keyscan -t ed25519 <host> | ssh-to-age      # or on the host: ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
# put the result in secrets/keys.nix under hosts, then:
nix run .#sops-config
sops updatekeys -y secrets/common.yaml          # + secrets/<host>.yaml if it exists
```

## Maintenance

### Removing a host, or a lost/stolen YubiKey

1. Delete its line from `secrets/keys.nix` and run `nix run .#sops-config`.
2. Re-encrypt **and rotate the data key** for each file it could read:
   ```bash
   sops updatekeys -y secrets/common.yaml   # drop the recipient
   sops rotate -i secrets/common.yaml       # new data key for the remaining recipients
   ```
   (`updatekeys` alone keeps the same data key, so a removed key that saw an old copy could
   still read new versions.)
3. If the key may actually be compromised, also **change the secret values themselves**,
   because old ciphertexts stay readable to that key in git history.

### Adding or replacing a YubiKey

```bash
ykman piv access change-pin && ykman piv access change-puk      # store both in 1Password
age-plugin-yubikey --generate --slot 1 --name "sops-$(ykman list --serials)" \
  --pin-policy once --touch-policy cached
age-plugin-yubikey --identity >> secrets/yubikey-identities.txt  # stub (not secret)
age-plugin-yubikey --list                                        # recipient -> secrets/keys.nix admins
nix run .#sops-config
for f in secrets/*.yaml; do sops updatekeys -y "$f"; done        # with an existing YubiKey plugged in
# then rebuild + re-burn the live USB (nixos-iso/) so it knows the new key
```

If a key's PIV PIN *and* PUK are both blocked: `ykman piv reset` wipes only PIV (FIDO2 login is
unaffected), then re-provision as above. Its old recipient becomes useless, so remove it.

### Break-glass

The private key is stored in 1Password only. To check it still works:
`sops-breakglass -d secrets/common.yaml >/dev/null && echo ok`.
To replace it: `age-keygen` → store the secret in 1Password → put the public key in `keys.nix`
`admins.breakglass` → `sops-config` → `updatekeys` every file → delete the local file.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `failed to get the data key` / `no identity matched any of the recipients` | No matching key available. Is a YubiKey plugged in? Is `SOPS_AGE_KEY_FILE` set (`echo $SOPS_AGE_KEY_FILE`; log out/in after first rebuild, or use `nix develop`)? Is this file one this host can read? |
| `age-plugin-yubikey` can't see the key | `pcscd` not running (`systemctl status pcscd.socket`), or another app (e.g. gpg's scdaemon) is holding the card: `gpgconf --kill scdaemon`. |
| PIN prompt never appears / hangs | sops needs a real terminal for the PIN prompt; run it directly, not from a non-interactive script. |
| Boot/rebuild: `sops-install-secrets: … failed to decrypt` | Host key not a recipient. Check `ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub` matches `keys.nix`, then `updatekeys`. |
| New secrets file "not found" during rebuild | It's untracked. `git add` it (flakes only see tracked files). |
| Editing `.sops.yaml` by hand got overwritten | It's generated. Edit `secrets/keys.nix` and run `nix run .#sops-config`. |
| `incorrect identity for recipient block` when using an SSH key via `SOPS_AGE_SSH_PRIVATE_KEY_FILE` | Host recipients are `ssh-to-age` X25519 keys; sops loads that variable as an `ssh-ed25519` identity, which only opens blocks encrypted to a raw `ssh-ed25519 AAAA…` recipient. Convert instead: `SOPS_AGE_KEY_CMD="ssh-to-age -private-key -i <key>"` (what `sops-host` does). |
