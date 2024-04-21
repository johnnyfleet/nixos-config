# #!/usr/bin/env bash
# ------------------------------------------------------------------
# [John Stephenson] setup.sh
# Provisions NixOs config on first setup. 
# ------------------------------------------------------------------

echo "Set up the config files correctly"
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bk
sudo ln -s ~/.config/nixos-config/configuration.nix /etc/nixos/configuration.nix
sudo mv ~/.config/nixos-config/hardware-configuration.nix ~/.config/nixos-config/hardware-configuration.nix.bk
sudo cp /etc/nixos/hardware-configuration.nix ~/.config/nixos-config/hardware-configuration.nix

echo "Switch to unstable branch"
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos

echo "Update system"
sudo nixos-rebuild switch --upgrade
