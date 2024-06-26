# nixos-config
Configuration for system setup, using Nix

Test update

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


## Quicker way

- `nix run --extra-experimental-features nix-command --extra-experimental-features flakes nixpkgs#git -- clone https://github.com/johnnyfleet/nixos-config ~/.config/nixos-config`
- `sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos`
- `sudo nixos-rebuild switch --upgrade`

## How to clean up

``` bash

sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

sudo nix-collect-garbage  --delete-old

sudo nix-collect-garbage  --delete-generations 1 2 3

# recommeneded to sometimes run as sudo to collect additional garbage
sudo nix-collect-garbage -d

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot
```

## Swap details
Add to hardware-configuration.nix

``` bash
 swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 2*1024;
  } ];
```
