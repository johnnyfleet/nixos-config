# MacBook setup — `john-macbook` (Intel, x86_64-darwin)

Copy-paste runbook for bringing up the work MacBook Pro with nix-darwin.

**Scope (slice 1):** CLI tools, zsh + aliases, Homebrew and 9 GUI apps.
**Not yet:** sops, tailscale, git config/SSH signing, GPG/YubiKey, VS Code settings.

---

## 0. Before you start

```bash
# Architecture — must say x86_64 for this config
uname -m

# macOS version — the `github` cask needs macOS 12+
sw_vers

# Your short username and hostname
whoami
scutil --get LocalHostName

# Admin rights (needed for the /nix volume and Homebrew).
# If this fails, stop — the whole plan is blocked by MDM policy.
sudo -v
```

If `whoami` is **not** `johnstephenson`, edit `darwinUser` in `flake.nix` (search
for `darwinUser =`). It's the single source of truth for the macOS account name —
both darwin modules take it as a specialArg, so it never needs editing in more
than one place.

---

## Fast path: one script

Both scripts below do steps 1–4 for you, backing up any conflicting `/etc`
shell files nix-darwin needs to own along the way. The only prompt you should
see is your password, for `sudo`. Everything from step 1 onwards in this doc is
the manual equivalent — useful if a script run fails partway, or you want to
read what it does before running it.

**No local clone, nothing else installed first** (doesn't need `git`):

```bash
curl -fsSL https://raw.githubusercontent.com/johnnyfleet/nixos-config/darwin-slice-1/scripts/darwin/bootstrap-remote.sh | bash
```

**Clones the repo first** — prefer this if you expect a few fix cycles, since
retries become local edit + local build instead of commit/push/`--refresh`:

```bash
curl -fsSL https://raw.githubusercontent.com/johnnyfleet/nixos-config/darwin-slice-1/scripts/darwin/bootstrap-local.sh | bash
```

Both scripts point at the `darwin-slice-1` branch. Once this work merges to
`main`, update `BRANCH` at the top of each script (and the URLs above).

Also you can then run

``` bash
nix --extra-experimental-features 'nix-command flake' run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake github:johnnyfleet/nixos-config/darwin-slice-1#john-macbook --refresh
```

---

## 1. Install Nix

> ⚠️ **Do not use the Determinate installer.** It dropped Intel macOS support in
> v3.13.2 (Nov 2025) and fails with `x86_64-darwin not found`.

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Restart your terminal, then enable flakes (the official installer does **not**
enable them by default):

```bash
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

> This must go in **`/etc/nix/nix.conf`**, not `~/.config/nix/nix.conf`. Step 4
> below runs `sudo nix run ...`, which reads root's config, not yours — a
> user-level config only fixes plain `nix` and leaves every `sudo nix` command
> failing with "experimental Nix feature 'flakes' is disabled". Writing it
> system-wide fixes both.

Verify:

```bash
nix --version
nix flake --help >/dev/null && echo "flakes OK"
```

---

## 2. Smoke test (no changes made)

Builds straight from GitHub. Nothing is installed, no sudo, nothing is modified —
this only proves the config evaluates and builds on real darwin.

```bash
nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  build --flake github:johnnyfleet/nixos-config/darwin-slice-1#john-macbook --refresh
```

**If this fails, stop and send the error.** Most likely culprits are
`system.primaryUser` or a `nix-homebrew` option name differing between the 26.05
branch and master.

---

## 3. Clone locally

Recommended even though step 2 works remotely — you will almost certainly need a
few fix cycles, and remote means commit + push + `--refresh` for every one.

```bash
git clone https://github.com/johnnyfleet/nixos-config ~/.config/nixos-config
cd ~/.config/nixos-config
git checkout darwin-slice-1
```

Re-run the build locally to confirm:

```bash
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  build --flake .#john-macbook
```
or

```bash
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  build --flake "github:johnnyfleet/nixos-config/darwin-slice-1#john-macbook"
```

---

## 4. Switch (this one changes the system)

`programs.zsh.enable` makes nix-darwin manage `/etc/zshrc`, and it manages
`/etc/bashrc` unconditionally regardless of that setting. macOS ships both by
default, and activation refuses to overwrite a plain file it doesn't already
own — so on a stock Mac this step fails the first time unless they're moved
aside first:

```bash
for f in /etc/zshrc /etc/zshenv /etc/zprofile /etc/bashrc /etc/bash.bashrc; do
  [ -f "$f" ] && [ ! -L "$f" ] && sudo mv "$f" "$f.before-nix-darwin"
done
```

Safe to run even if some of those files don't exist or are already
nix-darwin-managed symlinks — the checks skip them.

```bash
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake .#john-macbook
```
or fully remote

```bash
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake "github:johnnyfleet/nixos-config/darwin-slice-1#john-macbook"
```

This installs: the CLI tools, zsh config, Homebrew itself (via nix-homebrew),
and the 9 casks. First run takes a while — Homebrew downloads all the apps.

Open a **new terminal** afterwards.

---

## 5. Manual steps after first switch

**Set your terminal font**, or powerlevel10k renders as garbage:
Terminal.app → Settings → Profiles → Font → **MesloLGS NF**
(iTerm2: Settings → Profiles → Text → Font)

**Sign in to:** 1Password, Slack, Google Chrome, Google Drive, Obsidian.
Claude Code authenticates separately — run `claude` and follow its login flow.

Setup 1Password and enable ssh. Setup agent.toml (open up the ssh item in the vault (three dots) and configured for ssh).

**Verify:**

```bash
which eza btop gh jq devenv nvim claude   # from nix + brew
brew list --cask                          # the 9 apps
echo $SHELL                               # zsh
ll                                        # eza alias works
```

---

## Day-to-day

```bash
suu    # nh darwin switch ~/.config/nixos-config   (rebuild after edits)
sru    # rebuild straight from GitHub default branch
sgc    # garbage-collect + optimise store
nf     # fastfetch
```

Full rebuild without the alias:

```bash
darwin-rebuild switch --flake ~/.config/nixos-config#john-macbook
```

Roll back:

```bash
darwin-rebuild --rollback
```

---

## Notes & gotchas

**Always pass `#john-macbook`.** `darwin-rebuild` defaults to
`darwinConfigurations.$(hostname)`, which won't match until the Mac is renamed.

**Use the `nix-darwin-26.05` ref, not master.** This config is pinned to
`nixpkgs-26.05-darwin`; master's `darwin-rebuild` is a version mismatch.

**`--refresh` when building from GitHub.** Nix caches the tarball, so without it
you'll push a fix and silently re-run the old code.

**Homebrew `cleanup` is set to `"none"`.** Run `brew list` first — a work Mac may
have IT-installed packages. Changing it to `"zap"` would uninstall anything not
declared in `hosts/john-macbook/default.nix`.

**`gh` comes from nixpkgs, not Homebrew** — it's a formula, not a cask, and this
keeps it consistent with the Linux hosts.

**VS Code is a cask**, so its extensions and settings are not managed yet.
Don't enable `programs.vscode` here — it would install a second, nixpkgs copy.

**Retrying step 1 after a failed/partial install?** If the installer complains
about an existing `/etc/nix/nix.conf`, that's a leftover from the attempt that
didn't finish — `/nix/store` was never created, but the conf file was. Move it
aside (`sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.bak`) and re-run. Both
bootstrap scripts do this automatically now.

**No need to actually open a new terminal after step 1.** The installer only
requires it because it wires `PATH`/daemon env into `/etc/zshrc` and
`/etc/bashrc` for *new* shells. To pick that up in the current one instead:
`. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`. Both bootstrap
scripts do this automatically now.

---

## ⚠️ This machine has a deadline

`nixpkgs 26.05` is the **last release supporting x86_64-darwin**, with security
fixes **until the end of 2026**. Determinate Nix already dropped Intel in Nov 2025.

After that there is no supported nixpkgs for this host. Options at that point:
move everything to Homebrew, or replace the machine with Apple Silicon (at which
point this config needs only its nixpkgs input changed).

**Don't invest heavily in slice 2 on this machine** — sops, GPG and git signing
are real effort against a short runway.
