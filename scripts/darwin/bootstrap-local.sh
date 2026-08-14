#!/usr/bin/env bash
# Fresh-machine bootstrap for john-macbook — clones the repo locally first.
#
# Prefer this over bootstrap-remote.sh if you expect a few fix cycles: once
# cloned, every retry is a local edit + local build instead of a
# commit/push/--refresh round trip. Intended usage:
#
#   curl -fsSL https://raw.githubusercontent.com/johnnyfleet/nixos-config/darwin-slice-1/scripts/darwin/bootstrap-local.sh | bash
#
# The only interactive prompt you should see is your password (for sudo).
# See docs/macbook-setup.md for the manual equivalent of every step here, plus
# troubleshooting if something fails partway through.
set -euo pipefail

REPO_URL="https://github.com/johnnyfleet/nixos-config"
BRANCH="darwin-slice-1" # update after this merges to main
CLONE_DIR="${HOME}/.config/nixos-config"
DARWIN_REBUILD="github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild"

log() { printf '\n==> %s\n' "$1"; }

if [ "$(uname -s)" != "Darwin" ] || [ "$(uname -m)" != "x86_64" ]; then
  echo "error: this config targets x86_64-darwin (Intel macOS). Detected $(uname -s)/$(uname -m)." >&2
  exit 1
fi

log "Requesting admin rights (needed for Nix + Homebrew)..."
sudo -v
(while true; do sudo -n true; sleep 60; done) 2>/dev/null &
KEEPALIVE_PID=$!
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix (official installer, multi-user daemon)..."
  # Not the Determinate installer: it dropped Intel macOS support in v3.13.2.
  sh <(curl -L https://nixos.org/nix/install) --daemon
  export PATH="/nix/var/nix/profiles/default/bin:$PATH"
else
  log "Nix already installed, skipping."
fi

log "Enabling flakes system-wide..."
# Must be /etc/nix/nix.conf, not ~/.config/nix/nix.conf: the switch below runs
# as root via sudo, which never reads a user-level nix.conf.
sudo mkdir -p /etc/nix
if ! sudo grep -qxF 'experimental-features = nix-command flakes' /etc/nix/nix.conf 2>/dev/null; then
  echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf >/dev/null
  sudo launchctl kickstart -k system/org.nixos.nix-daemon
fi

if [ -d "$CLONE_DIR/.git" ]; then
  log "Repo already present at ${CLONE_DIR}, pulling latest ${BRANCH}..."
  git -C "$CLONE_DIR" fetch origin "$BRANCH"
  git -C "$CLONE_DIR" checkout "$BRANCH"
  git -C "$CLONE_DIR" pull --ff-only origin "$BRANCH"
else
  log "Cloning ${REPO_URL} into ${CLONE_DIR}..."
  if command -v git >/dev/null 2>&1; then
    git clone "$REPO_URL" "$CLONE_DIR"
  else
    nix run nixpkgs#git -- clone "$REPO_URL" "$CLONE_DIR"
  fi
  git -C "$CLONE_DIR" checkout "$BRANCH"
fi

log "Backing up any pre-existing shell rc files nix-darwin needs to own..."
for f in /etc/zshrc /etc/zshenv /etc/zprofile /etc/bashrc /etc/bash.bashrc; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    sudo mv "$f" "${f}.before-nix-darwin"
    echo "  moved $f -> ${f}.before-nix-darwin"
  fi
done

log "Building + switching to ${CLONE_DIR}#john-macbook (installs Homebrew + all casks — first run is slow)..."
cd "$CLONE_DIR"
sudo nix run "$DARWIN_REBUILD" -- switch --flake ".#john-macbook"

log "Done. Open a new terminal, then see 'Manual steps after first switch' in docs/macbook-setup.md (terminal font, app sign-ins)."
