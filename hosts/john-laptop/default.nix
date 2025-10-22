# Build this VM with nix build  ./#nixosConfigurations.vm.config.system.build.vm
# Then run is with: ./result/bin/run-nixos-vm
# To be able to connect with ssh enable port forwarding with:
# QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/run-nixos-vm
# Then connect with ssh -p 2222 guest@localhost
{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ##### Core Configuration
    ../common/core/default.nix
    inputs.sops-nix.nixosModules.sops

    ##### Set up users
    ../common/users/john.nix
    #../common/users/guest.nix

    ##### Optional Configuration
    ../common/optional/1password.nix
    ../common/optional/docker.nix
    ../common/optional/flatpak.nix
    #../common/optional/gnome.nix
    ../common/optional/tlp.nix
    #../common/optional/power-profiles.nix
    ../common/optional/plasma-minimal.nix
    #../common/optional/niri.nix
    ../common/optional/printing.nix
    #../common/optional/fwupd.nix
    ../common/optional/steam.nix
    ../common/optional/virtualisation.nix
    #../common/optional/virtualisation-bridge.nix
    #../common/optional/xfce-full.nix
    #../common/optional/xfce-minimal.nix
    #../common/optional/minecraft-bedrock-client.nix
    ../common/optional/node-sonos-http-firewall.nix
    #../common/optional/cloudflare-warp.nix
    ../common/optional/yubikey-authentication.nix
  ];

  ######################### NIX-SOPS ############################

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  #sops.age.keyFile = "/home/john/.config/sops/age/keys.txt";
  sops.age.keyFile = "//var/lib/sops-nix/key.txt";

  sops.secrets.john-password = {
    owner = "john";
    neededForUsers = true;
  };

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # Force update passwords for users on each run.
  users.mutableUsers = true;

  ############################ NETWORKING ########################

  # Set hostname - the rest of networking is taken care of by the common config.
  networking.hostName = "john-laptop";

  ##################### BOOTLOADER ##########################
  # After switching bootloader - reinstall with 
  # sudo nixos-rebuild --install-bootloader boot

  # Grub Bootloader
  #boot.loader.systemd-boot.enable = false;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.enable = true;
  #boot.loader.grub.devices = [ "nodev" ];
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.useOSProber = true;

  # Systemd-boot Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

  # Switch to Zen linux kernel for slightly smoother gameplay. 
  #boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_latest;


  ########################## PACKAGES ##############################

  # Override tailscale to skip failing tests
  nixpkgs.overlays = [
    (final: prev: {
      tailscale = prev.tailscale.overrideAttrs (oldAttrs: {
        doCheck = false;  # Disable tests to avoid portlist test failures
      });
    })
  ];

  /* # Enable fingerprint 
  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
  security.pam.services.login.fprintAuth = false; #disable fingerprint login - but allow everything else. */ 

  # Included packages here
  #environment.systemPackages = with pkgs; [ ];


  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # Set memory to 4GB
      cores = 2;        # You can also set the number of CPU cores here
     };
  };
  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
