# Build this VM with nix build  ./#nixosConfigurations.vm.config.system.build.vm
# Then run is with: ./result/bin/run-nixos-vm
# To be able to connect with ssh enable port forwarding with:
# QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/run-nixos-vm
# Then connect with ssh -p 2222 guest@localhost
{ lib, config, inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ##### Disko setup
    ./disk-config.nix

    ##### Core Configuration
    ../common/core/default.nix
    inputs.sops-nix.nixosModules.sops

    ##### Set up users
    ../common/users/john.nix
    ../common/users/guest.nix

    ##### Optional Configuration
    ../common/optional/1password.nix
    #../common/optional/docker.nix
    #../common/optional/flatpak.nix
    #../common/optional/gnome.nix
    ../common/optional/plasma-minimal.nix
    #../common/optional/printing.nix
    #../common/optional/steam.nix
    #../common/optional/virtualisation.nix
    #../common/optional/xfce-full.nix
    #../common/optional/xfce-minimal.nix
    #../common/optional/minecraft-bedrock-client.nix
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
  users.mutableUsers = false;

########################## OTHER CONFIG ############################


 # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  #boot.loader.grub.enable = true;
  #boot.loader.grub.device = "/dev/vda";
  #boot.loader.grub.useOSProber = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ########################## VIRTUALISATION ########################

  # Options for the screen
  virtualisation.vmVariant = {
    virtualisation.resolution = {
      x = 1280;
      y = 1024;
    };
    virtualisation.cores = 4;
    virtualisation.memorySize =  2048;
    virtualisation.qemu.options = [
      # Better display option
      "-vga virtio"
      "-display gtk,zoom-to-fit=false,show-cursor=on"
      # Enable copy/paste
      # https://www.kraxel.org/blog/2021/05/qemu-cut-paste/
      "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
      "-device virtio-serial-pci"
      "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"
    ];
  };

  # VM guest additions to improve host-guest interaction
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  services.spice-autorandr.enable = true;


  ############################# USERS #############################

  security.sudo.wheelNeedsPassword = false;
  users.users.root.openssh.authorizedKeys.keys =
    let
      authorizedKeys = pkgs.fetchurl {
        url = "https://github.com/johnnyfleet.keys";
        sha256 = "fce5536148d8d8f607dc0612d47c9ca721a75c62539a07e571183f56070c31d1";
      };
    in
    pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);


 ############################# DISPLAY #########################
/*
  # X configuration
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  services.displayManager.autoLogin.user = "john";
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.enableScreensaver = false;

  #services.xserver.videoDrivers = [ "qxl" ]; */

########################## PACKAGES ##############################


  # Included packages here
  #nixpkgs.config.allowUnfree = true;
  #environment.systemPackages = with pkgs; [ ];

  system.stateVersion = "22.11";
}
