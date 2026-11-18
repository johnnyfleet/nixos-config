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
}: {
  imports = [
    ./hardware-configuration.nix

    ##### Disko setup
    ./disk-config.nix

    ##### Core Configuration
    ../common/core/default.nix

    ##### Set up users
    ../common/users/john.nix
    #../common/users/guest.nix

    ##### Optional Configuration - Converted modules
    ../common/optional/1password.nix
    ../common/optional/docker.nix
    ../common/optional/syncthing.nix
    ../common/optional/steam.nix
    ../common/optional/virtualisation.nix

    ##### Optional Configuration - Legacy modules
    ../common/optional/flatpak.nix
    #../common/optional/gnome.nix
    ../common/optional/tlp.nix
    ../common/optional/plasma-minimal.nix
    #../common/optional/niri.nix
    #../common/optional/printing.nix
    #../common/optional/virtualisation-bridge.nix
    #../common/optional/xfce-full.nix
    #../common/optional/xfce-minimal.nix
    #../common/optional/minecraft-bedrock-client.nix
    #../common/optional/node-sonos-http-firewall.nix
    #../common/optional/cloudflare-warp.nix
  ];

  ######################### MODULE CONFIGURATION ##########################

  modules._1password = {
    enable = true;
    polkitPolicyOwners = ["john"];
  };

  modules.docker = {
    enable = true;
    users = ["john"];
  };

  # Syncthing disabled in VM
  modules.syncthing.enable = false;

  modules.steam = {
    enable = true;
  };

  # Virtualisation not needed inside VM
  modules.virtualisation.enable = false;

  ######################### NIX-SOPS ############################

  # Shared wiring is in hosts/common/core/sops.nix. Declare secrets here, e.g.
  #   sops.secrets.john-password.neededForUsers = true;

  ############################ NETWORKING ########################

  # Set hostname - the rest of networking is taken care of by the common config.
  networking.hostName = "vm";

  ########################## OTHER CONFIG ############################

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
    virtualisation.memorySize = 2048;
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
  users.users.root.openssh.authorizedKeys.keys = let
    authorizedKeys = pkgs.fetchurl {
      url = "https://github.com/johnnyfleet.keys";
      sha256 = "sha256-2FhN+k1RYwKog9baQMpdApTHGfZScZtpn6MJBBnUm2E=";
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

  #services.xserver.videoDrivers = [ "qxl" ];
  */

  ########################## PACKAGES ##############################

  # Included packages here
  #nixpkgs.config.allowUnfree = true;
  #environment.systemPackages = with pkgs; [ ];

  system.stateVersion = "22.11";
}
