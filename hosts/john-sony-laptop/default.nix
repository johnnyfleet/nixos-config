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
    inputs.sops-nix.nixosModules.sops

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

  /*
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
  */

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

  # Enable Xorg so the X11 Plasma session (plasmax11, set below) is available,
  # and turn on the radeon DDX TearFree option for a vsync that survives
  # suspend/resume. modesetting (Intel) ignores this option harmlessly.
  services.xserver.enable = true;
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';

  ########################### USERS ################################

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "kiran"; # replace with your username
    };

    # The HD 7650M uses the legacy `radeon` driver, which has no atomic KMS.
    # KWin Wayland loses its tear-free page-flip path across suspend/resume
    # on this driver, so tearing returns after sleep. Run the X11 Plasma
    # session instead (KWin's X11 compositor re-establishes vsync on resume),
    # and keep the SDDM greeter on X11 too so there is no Wayland->X11 handoff
    # on this fragile GPU. radeon.runpm=0 (hardware-configuration.nix) handles
    # the separate resume-corruption issue; the TearFree option below handles
    # vsync. These override plasma-minimal.nix, which is shared with other
    # hosts that stay on Wayland.
    defaultSession = lib.mkForce "plasmax11";
    sddm.wayland.enable = lib.mkForce false;
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
