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
    ../common/users/john.nix
    #../common/users/guest.nix
    ../common/optional/plasma-minimal.nix
    #../common/optional/xfce-full.nix
    ../common/optional/1password.nix
    ../common/optional/flatpak.nix
    ../common/optional/steam.nix
    ../common/core/gc-optimise.nix
    ../common/core/regular-programs.nix
    inputs.sops-nix.nixosModules.sops
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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ##################### BOOTLOADER ##########################
  # After switching bootloader - reinstall with 
  # sudo nixos-rebuild --install-bootloader boot

  # Grub Bootloader
  boot.loader.systemd-boot.enable = false;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.useOSProber = true;

  # Systemd-boot Bootloader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.enable = false;


  # Downgrade kernal version to see if fixes tearing from suspend. This seems to work.
  #boot.kernelPackages = pkgs.linuxPackages_5_10;

  #boot.loader.systemd-boot.enable = true;linuxPackages_latest
  #boot.loader.efi.canTouchEfiVariables = true;

  ############################ NETWORKING ########################

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "john-sony-laptop";
  services.tailscale.enable = true;

  services.avahi.enable = true;
  
  #Switch to more modern nftables implementation
  networking.nftables.enable = true;
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # let you SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };

  ############################## LOCALE ##############################
  console.keyMap = "us";

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  ########################## VIRTUALISATION ########################

  /*
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
  */

  #security.sudo.wheelNeedsPassword = false;

  /*
    # Set the default shell as zsh
    programs.zsh.enable = true;
    users.users.john.shell = pkgs.zsh;
  */

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

  # Enable ssh & fail2ban
  services.sshd.enable = true;
  services.fail2ban.enable = true;


  # Enable smartcard reader - for Yubikey reading.
  services.pcscd.enable = true;

  # Included packages here
  #nixpkgs.config.allowUnfree = true;
  #environment.systemPackages = with pkgs; [ ];

  system.stateVersion = "22.11";
}
