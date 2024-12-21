# nixos-config
Configuration for system setup using Nix flakes and NixOS.

This repository contains the configuration files and scripts to set up and manage a NixOS system using Nix flakes. It includes configurations for different hosts, user environments, and various services.

## Features
- **Declarative Configuration**: Manage your system configuration declaratively using Nix.
- **Multi-Host Setup**: Configurations for different machines, including laptops and virtual machines.
- **Home Manager Integration**: Manage user-specific configurations with Home Manager.
- **Secrets Management**: Securely manage secrets using SOPS.
- **Flakes Support**: Utilize Nix flakes for reproducible builds and configurations.

## Initial setup
After a fresh install of NixOS

### If configuring from another machine
i.e. if this is a vm. 

1. Enable OpenSSH inconfig and rebuild
2. Manually create authorized keys and add github stored public keys in
    - `curl https://github.com/johnnyfleet.keys >> ~/.ssh/authorized_keys`
3. Set up and access key to access github using [these github instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    - `ssh-keygen -t ed25519 -C "<user@email>"`
    - Start ssh-agent in background `eval "$(ssh-agent -s)"`
    - `ssh-add ~/.ssh/id_ed25519`
4. Add public keys to GitHub account
5. Now follow instructions from [nix-sops](https://github.com/Mic92/sops-nix) to get a public key for my target machine. 
    - `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`
    - Copy the resulting key. Add to `.sops.yaml` on host machine. 
    - Run `sops updatekeys secrets/secrets.yaml`
    - run `curl https://github.com/johnnyfleet.keys | sha256sum` to generate new sha for github page. Add that to the user setup for authorised keys. This ensures that the checksum is correct when downloading. 
6. Commit to git and push up changes. 

7. Clone the repo onto the machine
    - `cd ~/.config/`
    - `git clone git@github.com:johnnyfleet/nixos-config.git`

8. Copy over the hardware configuration to the repo in the right location
    - `cd nixos-config`
    - `sudo mv /etc/nixos/hardware-configuration.nix ./hosts/<your host>/hardware-configuration.nix`

9. Add swap details in if required for this machine. 
  Add to hardware-configuration.nix

  ``` bash
  swapDevices = [ {
      device = "/var/lib/swapfile";
      size = 2*1024;
    } ];
  ```

9. Go!
- `sudo nixos-rebuild switch --flake ~/.config/nixos-config#vm`



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

## Directory Structure
```
.gitignore
.sops.yaml
flake.lock
flake.nix
home/
  john/
    core/
      default.nix
      zsh/
        default.nix
        p10k/
          p10k.zsh
    john-laptop.nix
    nixos-anywhere-vm.nix
hosts/
  common/
    common.nix
    core/
      configuration.nix
    optional/
      gnome.nix
      plasma.nix
      xfce.nix
    users/
      guest.nix
      john.nix
  john-laptop/
    configuration.nix
  nixos-anywhere-vm/
    default.nix
    hardware-configuration.nix
    nixos-vm-new-example.nix
LICENSE
README.md
secrets/
  secrets.yaml
setup.sh
```

## Usage
### Building the VM
To build the VM, run:
```sh
nix build ./#nixosConfigurations.vm.config.system.build.vm
```
To run the VM:
```sh
./result/bin/run-nixos-vm
```

### Managing Secrets
This repository uses SOPS for secrets management. Ensure you have the necessary keys and configuration in place.

## Contributing
This is primarily for my use. feel free to open issues or submit pull requests if you find any bugs or have suggestions for improvements - but I'll focus on being helpful for me over useful for others. 

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.