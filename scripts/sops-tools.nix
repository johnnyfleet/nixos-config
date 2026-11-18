# Helper commands for the sops workflow. See docs/sops.md.
# Installed on every host by hosts/common/core/sops.nix, and exposed as flake apps
# (`nix run .#sops-new-host -- <host>`) for machines that aren't built from this flake yet.
{
  writeShellApplication,
  symlinkJoin,
  git,
  nix,
  sops,
  age,
  age-plugin-yubikey,
  ssh-to-age,
  openssh,
  gnused,
  gnugrep,
  coreutils,
}: let
  # Regenerate .sops.yaml from secrets/keys.nix (run from anywhere inside the repo).
  sops-config = writeShellApplication {
    name = "sops-config";
    runtimeInputs = [git nix coreutils];
    text = ''
      root=$(git rev-parse --show-toplevel)
      nix eval --impure --raw --expr \
        "import $root/secrets/sops-config.nix (import $root/secrets/keys.nix)" \
        > "$root/.sops.yaml"
      echo "wrote $root/.sops.yaml"
    '';
  };

  # Pre-generate a host's SSH key, register it as a sops recipient and re-encrypt.
  sops-new-host = writeShellApplication {
    name = "sops-new-host";
    runtimeInputs = [git sops age age-plugin-yubikey ssh-to-age openssh gnused gnugrep coreutils sops-config];
    text = ''
      usage() {
        cat <<EOF
      usage: sops-new-host <hostname> [--out DIR]

        Generates DIR/etc/ssh/ssh_host_ed25519_key (reused if it already exists), adds its
        age recipient to secrets/keys.nix, regenerates .sops.yaml and re-encrypts
        secrets/common.yaml (+ secrets/<hostname>.yaml if present). Needs a YubiKey.

        --out DIR   where to put etc/ssh/ (default: a new temp dir). Run as your normal
                    user (git refuses a repo owned by someone else), then sudo cp the key
                    into /mnt/etc/ssh/ on the live USB.
      EOF
        exit 1
      }

      [[ $# -ge 1 ]] || usage
      host=$1; shift
      out=""
      while [[ $# -gt 0 ]]; do
        case $1 in
          --out) out=$2; shift 2 ;;
          *) usage ;;
        esac
      done
      [[ $host =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "bad hostname: $host" >&2; exit 1; }

      root=$(git rev-parse --show-toplevel)
      cd "$root"
      [[ -z $out ]] && out=$(mktemp -d "''${TMPDIR:-/tmp}/sops-new-host-$host.XXXXXX")

      umask 077
      mkdir -p "$out/etc/ssh"
      chmod 755 "$out/etc" "$out/etc/ssh"
      key="$out/etc/ssh/ssh_host_ed25519_key"
      if [[ -f $key ]]; then
        echo "reusing existing host key $key"
      else
        ssh-keygen -q -t ed25519 -N "" -C "root@$host" -f "$key"
      fi
      chmod 600 "$key"
      chmod 644 "$key.pub"
      recipient=$(ssh-to-age -i "$key.pub")
      echo "$host -> $recipient"

      if grep -qE "^ +$host = " secrets/keys.nix; then
        sed -i -E "s|^( +$host = ).*|\1\"$recipient\";|" secrets/keys.nix
      else
        sed -i -E "s|^( +)# sops-new-host inserts|\1$host = \"$recipient\";\n\1# sops-new-host inserts|" secrets/keys.nix
      fi
      sops-config

      files=(secrets/common.yaml)
      [[ -f secrets/$host.yaml ]] && files+=("secrets/$host.yaml")
      echo "re-encrypting ''${files[*]} (enter YubiKey PIN / touch when it blinks)"
      for f in "''${files[@]}"; do sops updatekeys -y "$f"; done
      git add secrets/keys.nix .sops.yaml "''${files[@]}"

      cat <<EOF

      Done. Host key is in: $out/etc/ssh/
        (contains a PRIVATE key - save it to 1Password if you want to be able to reinstall
         this host with the same identity, then delete the directory after install)

      nixos-anywhere:
        nixos-anywhere --extra-files $out --flake .#$host <user>@<ip>

      live USB (if --out wasn't /mnt):
        sudo mkdir -p /mnt/etc/ssh && sudo cp -a $out/etc/ssh/ssh_host_ed25519_key* /mnt/etc/ssh/

      Then commit: git commit -m "feat: add $host sops recipient"
      EOF
    '';
  };

  # Use the break-glass key from 1Password for one sops invocation:
  #   sops-breakglass secrets/common.yaml
  #   sops-breakglass updatekeys -y secrets/common.yaml
  # Uses the system `op` (the /run/wrappers one talks to the 1Password desktop app for unlock),
  # not a store copy - which also keeps this flake app free of unfree packages.
  sops-breakglass-key = writeShellApplication {
    name = "sops-breakglass-key";
    runtimeInputs = [];
    text = ''
      command -v op >/dev/null || { echo "sops-breakglass: 1Password CLI (op) not on PATH" >&2; exit 1; }
      op read "''${SOPS_BREAKGLASS_OP_REF:-op://Private/NixOS - SOPs Break Glass John age key/age key}"
    '';
  };
  sops-breakglass = writeShellApplication {
    name = "sops-breakglass";
    runtimeInputs = [sops];
    text = ''
      unset SOPS_AGE_KEY_FILE
      export SOPS_AGE_KEY_CMD=${sops-breakglass-key}/bin/sops-breakglass-key
      exec sops "$@"
    '';
  };

  # Edit using this machine's SSH host key (via sudo) - for when no YubiKey is to hand.
  # Can only open files this host is a recipient of (common.yaml, <this-host>.yaml).
  #
  # Host recipients in keys.nix are ssh-to-age *X25519* keys, so the private key must be
  # converted the same way (as sops-nix does at boot). SOPS_AGE_SSH_PRIVATE_KEY_FILE won't
  # work: sops loads that as an ssh-ed25519 identity, which can't open X25519 blocks.
  # The converted key is only ever on a pipe, never on disk.
  sops-host = writeShellApplication {
    name = "sops-host";
    runtimeInputs = [sops];
    text = ''
      exec sudo env -u SOPS_AGE_KEY_FILE \
        SOPS_AGE_KEY_CMD="${ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key" \
        EDITOR="''${EDITOR:-nano}" \
        "$(command -v sops)" "$@"
    '';
  };
in
  symlinkJoin {
    name = "sops-tools";
    paths = [sops-config sops-new-host sops-breakglass sops-host];
    passthru = {inherit sops-config sops-new-host sops-breakglass sops-host;};
  }
