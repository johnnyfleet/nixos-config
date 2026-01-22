# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration repository managing multiple machines with Home Manager integration and SOPS secrets management.

## Common Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake ~/.config/nixos-config#<hostname>

# Available hostnames: john-laptop, john-sony-laptop, vm

# Check flake for errors
nix flake check

# Format nix files (uses alejandra formatter)
nix fmt

# Update flake inputs
nix flake update

# Build VM for testing
nix build ./#nixosConfigurations.vm.config.system.build.vm
./result/bin/run-nixos-vm

# Update SOPS secrets after adding new host key
sops updatekeys secrets/secrets.yaml
```

## Architecture

### Directory Structure

- `flake.nix` - Main entry point defining all nixosConfigurations
- `hosts/` - Machine-specific configurations
  - `hosts/<hostname>/default.nix` - Host entry point, imports core + optional modules
  - `hosts/<hostname>/hardware-configuration.nix` - Hardware-specific settings
  - `hosts/common/core/` - Modules imported by all hosts (base config, yubikey, gc)
  - `hosts/common/optional/` - Feature modules (desktop environments, docker, steam, etc.)
  - `hosts/common/users/` - User account definitions
- `home/` - Home Manager configurations per user
  - `home/<user>/core/` - Core user config (zsh, gnupg, editor, git)
  - `home/<user>/optional/` - Optional user features (gaming, dev-tools, work apps)
  - `home/<user>/<hostname>.nix` - Per-host user configuration entry point
- `secrets/` - SOPS-encrypted secrets (secrets.yaml)

### Key Patterns

**Adding features to a host**: Import the module in `hosts/<hostname>/default.nix` from `hosts/common/optional/`

**Adding user features**: Import the module in `home/<user>/<hostname>.nix` from `home/<user>/optional/`

**Secrets**: Managed via sops-nix. Keys are defined in `.sops.yaml`. Secrets accessed via `sops.secrets.<name>`

### Flake Inputs

- `nixpkgs` - nixos-unstable channel
- `home-manager` - User environment management
- `sops-nix` - Secrets management
- `plasma-manager` - KDE Plasma configuration
- `nixos-hardware` - Hardware-specific optimizations
- `disko` - Declarative disk partitioning
- `nix-index-database` - Command-not-found with comma
- `zen-browser`, `niri` - Additional packages
