#!/usr/bin/env bash
# Fresh-machine bootstrap for john-macbook — no local clone, no git required.
#
# Installs Nix, then builds and switches straight from GitHub. Intended usage:
#
#   curl -fsSL https://raw.githubusercontent.com/johnnyfleet/nixos-config/darwin-slice-1/scripts/darwin/bootstrap-remote.sh | bash
#
# The only interactive prompt you should see is your password (for sudo).
# See docs/macbook-setup.md for the manual equivalent of every step here, plus
# troubleshooting if something fails partway through.
set -euo pipefail

REPO="johnnyfleet/nixos-config"
BRANCH="darwin-slice-1" # update after this merges to main
FLAKE_TARGET="github:${REPO}/${BRANCH}#john-macbook"
DARWIN_REBUILD="github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild"

log() { printf '\n==> %s\n' "$1"; }

if [ "$(uname -s)" != "Darwin" ] || [ "$(uname -m)" != "x86_64" ]; then
  echo "error: this config targets x86_64-darwin (Intel macOS). Detected $(uname -s)/$(uname -m)." >&2
  exit 1
fi

log "Requesting admin rights (needed for Nix + Homebrew)..."
sudo -v
# Keep the sudo timestamp alive for the whole run — Homebrew's first cask
# download can take a while, and we don't want a second password prompt.
(while true; do sudo -n true; sleep 60; done) 2>/dev/null &
KEEPALIVE_PID=$!
trap 'kill "$KEEPALIVE_PID" 2>/dev/null || true' EXIT

if ! command -v nix >/dev/null 2>&1; then
  # A previous failed/partial install can leave /etc/nix/nix.conf behind even
  # though /nix/store never got created. The installer refuses to run its
  # multi-user setup again while that file is there, so clear it out first.
  if [ -e /etc/nix/nix.conf ] && [ ! -d /nix/store ]; then
    log "Found a leftover /etc/nix/nix.conf from a previous install attempt — backing it up so the installer can run clean..."
    sudo mv /etc/nix/nix.conf "/etc/nix/nix.conf.before-nix-darwin-$(date +%s)"
  fi

  log "Installing Nix (official installer, multi-user daemon)..."
  # Not the Determinate installer: it dropped Intel macOS support in v3.13.2.
  sh <(curl -L https://nixos.org/nix/install) --daemon

  # The installer wires PATH and daemon env into /etc/zshrc and /etc/bashrc
  # for new shells. Source the same file directly instead of requiring a new
  # terminal window mid-script.
  NIX_DAEMON_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  if [ -e "$NIX_DAEMON_SCRIPT" ]; then
    . "$NIX_DAEMON_SCRIPT"
  else
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
  fi
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

log "Backing up any pre-existing shell rc files nix-darwin needs to own..."
for f in /etc/zshrc /etc/zshenv /etc/zprofile /etc/bashrc /etc/bash.bashrc; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    sudo mv "$f" "${f}.before-nix-darwin"
    echo "  moved $f -> ${f}.before-nix-darwin"
  fi
done

log "Building + switching to ${FLAKE_TARGET} (installs Homebrew + all casks — first run is slow)..."
sudo nix run "$DARWIN_REBUILD" -- switch --flake "$FLAKE_TARGET" --refresh

log "Done. Open a new terminal, then see 'Manual steps after first switch' in docs/macbook-setup.md (terminal font, app sign-ins)."
