# nixos-config
Configuration for system setup, using Nix


## Initial setup
After a fresh install of NixOS

- `ssh-keygen -t ed25519 -C "<user@email>"`
- `eval "$(ssh-agent -s)"`
- `ssh-add ~/.ssh/id_ed25519`
- Add public keys to GitHub account
- `cd ~/.config/`
- `git clone git@github.com:johnnyfleet/nixos-config.git`
- `sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bk`
- `sudo ln ~/.config/nixos-config/configuration.nix /etc/nixos/configuration.nix`
- `sudo nixos-rebuild switch`
