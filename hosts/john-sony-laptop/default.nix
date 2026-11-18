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

    ##### Core Configuration
    ../common/core/default.nix

    ##### Disko setup
    ./disk-config.nix

    ##### Set up users
    ../common/users/john.nix
    ../common/users/kiran.nix
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
    ../common/optional/power-profiles.nix
    #../common/optional/tlp.nix
    ../common/optional/plasma-minimal.nix
    ../common/optional/printing.nix
    #../common/optional/xfce-full.nix
    #../common/optional/xfce-minimal.nix
    #../common/optional/minecraft-bedrock-client.nix
  ];

  ######################### MODULE CONFIGURATION ##########################

  modules._1password = {
    enable = true;
    polkitPolicyOwners = [
      "john"
      "kiran"
    ];
  };

  # Docker disabled on this machine
  modules.docker.enable = false;

  # Syncthing disabled on this machine
  modules.syncthing.enable = false;

  modules.steam = {
    enable = true;
  };

  # Virtualisation disabled on this machine
  modules.virtualisation.enable = false;

  ######################### NIX-SOPS ############################

  # Shared wiring is in hosts/common/core/sops.nix. Declare secrets here, e.g.
  #   sops.secrets.john-password.neededForUsers = true;

  ############################ NETWORKING ########################

  # Set hostname - the rest of networking is taken care of by the common config.
  networking.hostName = "john-sony-laptop";

  ##################### BOOTLOADER ##########################
  # After switching bootloader - reinstall with
  # sudo nixos-rebuild --install-bootloader boot

  # Grub Bootloader
  boot.loader.systemd-boot.enable = false;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = ["nodev"];
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.useOSProber = true;

  # Systemd-boot Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.enable = false;

  # Downgrade kernal version to see if fixes tearing from suspend. This seems to work.
  #boot.kernelPackages = pkgs.linuxPackages_5_10;

  ######################## WORKAROUNDS #############################

  # Fix chrome screen tearing on old AMD graphics cards in Wayland sessions.

  #TODO: FIXME - this is not working yet. You need to add the below arguments to the chrome shortcut before the %U.
  #I need to find a way to override this in NixOS for simplicity.
  /*
     programs.google-chrome.commandLineArgs = [
    "--ozone-platform-hint=wayland"
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
    "--use-gl=egl"
    "--disable-vulkan"
    "--enable-gpu-rasterization"
  ];
  */

  ########################### USERS ################################

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "kiran"; # replace with your username
    };

    # Session comes from plasma-minimal.nix (Plasma Wayland). This host ran plasmax11
    # (61ffbf8) because the HD 7650M's legacy `radeon` driver has no atomic KMS and KWin
    # Wayland lost tear-free page flips across suspend/resume. Plasma's X11 session was
    # removed from nixpkgs (Nov 2026), so it's back on Wayland. If tearing after resume
    # returns, the X11 fallback is xfce-minimal.nix with xserver.deviceSection TearFree.
    # radeon.runpm=0 (hardware-configuration.nix) still covers the resume-corruption issue.
  };

  ########################## PACKAGES ##############################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
