# images/base-config.nix
{ lib
, pkgs
, ...
}:
{
  imports = [
    # ../modules/base-system.nix
    # ../modules/services/numlock-on-tty
  ];

  networking = {
    useDHCP = false;
    hostName = "my-nixos-live"; # default: "nixos"
    usePredictableInterfaceNames = false;
    interfaces.eth0.useDHCP = true;
    # interfaces.eth0.ipv4.addresses = [
    #   {
    #     address = "192.168.1.2";
    #     prefixLength = 24;
    #   }
    # ];
    # defaultGateway = "192.168.1.1";
    # nameservers = [ "192.168.1.1" "1.1.1.1" "8.8.8.8" ];
  };

  boot.supportedFilesystems = [ "zfs" "f2fs" ];
  # serial connection for apu
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = 
    let
      authorizedKeys = pkgs.fetchurl {
        url = "https://github.com/johnnyfleet.keys";
        sha256 = "fce5536148d8d8f607dc0612d47c9ca721a75c62539a07e571183f56070c31d1";
      };
    in
      pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);

  users.users = {
    "nixos" = {
      isNormalUser = true;
      home = "/home/nixos";
      hashedPassword = "";
      uid = 1000;
      extraGroups = [ "systemd-journal" "wheel" ];
      openssh.authorizedKeys.keys =
        let
        authorizedKeys = pkgs.fetchurl {
          url = "https://github.com/johnnyfleet.keys";
          sha256 = "fce5536148d8d8f607dc0612d47c9ca721a75c62539a07e571183f56070c31d1";
        };
        in
          pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
    };
  };

  # sshd
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    #settings.PermitRootLogin = lib.mkDefault "prohibit-password";
    hostKeys = [
      { type = "rsa"; bits = 4096; path = "/etc/ssh/ssh_host_rsa_key"; }
      { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.addresses = true;
    publish.domain = true;
    publish.enable = true;
    publish.userServices = true;
    publish.workstation = true;
  };

  # Turn on flakes.
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # includes this flake in the live iso : "/etc/nixcfg"
  environment.etc.nixcfg.source =
    builtins.filterSource
      (path: type:
        baseNameOf path
        != ".git"
        && type != "symlink"
        && !(pkgs.lib.hasSuffix ".qcow2" path)
        && baseNameOf path != "secrets")
      ../.;

  ## FIX for running out of space / tmp, which is used for building
  fileSystems."/nix/.rw-store" = {
    fsType = "tmpfs";
    options = [ "mode=0755" "nosuid" "nodev" "relatime" "size=14G" ];
    neededForBoot = true;
  };


 ############################## LOCALE ############################
  console.keyMap = lib.mkDefault "us";

  # Set your time zone.
  time.timeZone = lib.mkDefault "Pacific/Auckland";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
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
    supportedLocales = lib.mkDefault [
      "en_GB.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };
  environment.variables = {
    TERM = "xterm-256color";
  };

  # # Use a high-res font.
  # boot.loader.systemd-boot.consoleMode = "0";
  console = {
    # https://github.com/NixOS/nixpkgs/issues/114698
    earlySetup = true; # Sets the font size much earlier in the boot process
    colors = [
      # # frappe colors
      "51576d"
      "e78284"
      "a6d189"
      "e5c890"
      "8caaee"
      "f4b8e4"
      "81c8be"
      "b5bfe2"
      "626880"
      "e78284"
      "a6d189"
      "e5c890"
      "8caaee"
      "f4b8e4"
      "81c8be"
      "a5adce"
    ];
    font = "Lat2-Terminus16";
    useXkbConfig = true; # Use same config for linux console
  };

  services.xserver = {
    enable = lib.mkDefault false; # but still here so we can copy the XKB config to TTYs
    autoRepeatDelay = 300;
    autoRepeatInterval = 35;
  } // lib.optionalAttrs false {
    xkbVariant = "colemak";
    xkbOptions = "caps:super,compose:ralt,shift:both_capslock";
  };
}