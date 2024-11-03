# Build this VM with nix build  ./#nixosConfigurations.vm.config.system.build.vm
# Then run is with: ./result/bin/run-nixos-vm
# To be able to connect with ssh enable port forwarding with:
# QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/run-nixos-vm
# Then connect with ssh -p 2222 guest@localhost
{ lib, config, inputs, pkgs, ... }:
{
  imports = [
      ./hardware-configuration.nix
      inputs.sops-nix.nixosModules.sops
    ];


  ######################### NIX-SOPS ############################

  sops.defaultSopsFile = ./secrets/secrets.yaml;
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


  users.mutableUsers = false;

########################## OTHER CONFIG ############################


 # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  ############################ NETWORKING ########################

  # Enable networking
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;


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

  # A default user able to use sudo
  users.users.guest = {
    isNormalUser = true;
    home = "/home/guest";
    extraGroups = [ "wheel" ];
    initialPassword = "guest";
    openssh.authorizedKeys.keyFiles = [ builtins.readFile (builtins.fetchurl https://github.com/johnnyfleet.keys ) ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.john = {
    isNormalUser = true;
    description = "John Stephenson";
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.john-password.path;
    #hashedPassword = lib.mkIf (builtins.pathExists config.sops.secrets.john-password.path) (builtins.readFile config.sops.secrets.john-password.path);
    #hashedPassword = "$y$j9T$cpXPtJL4zO0GkCbJEPkYI0$jvqOMxV9xOuSFRve2U02/HWTLY2DJ8zV2eFGfafHxG4";
    openssh.authorizedKeys.keys = [
      # change this to your ssh key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGsZulli5DsPnutXKm4OBOXcbHkPsZubDj4Q1FjEjyQD johnnyfleet@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMTDc8z82RScvsTWcx5opqWIbkaEs51K2oWc94K3uginFKe7qLEjEcoEGlP+9L5IyFQmRv/fiFzE5ZGEho1bUxZu8/kHmK8oC+gdNx2vJlf/plVh6qnO8lQ9KOd2nPj8hUTTPl/ZbMl8FpOnT/9giySTJS+NvHL9ApU8tGLW2QH832WY3wzgnFlhDm4acm9Xir3p3f3ucbLf22z5Gu66NAhy9/M2B+Sx8ZYkHCFzf7PWRgiBHJgD3krfAhPEU2/LRq5Kw8ea60Ch2nUFzij+Dnqg1Z5/ikM3hrmYolKmLLCpZBqU9X82oSUTmuJS4hioMQ4kfu3KbabdjIpjhn8yePJ2Re26po6kEE9LsChpmtXQRSRAWbgAp6OxccdCaCkG8yUKZKgxiS5RbBqj6HEtBpBcFx7DGLE/nyKvzD4VRGSZnIYI+s1kcLX90pdLVrjfGAboQ0kwpxt3LvSMwbU52LxPw9UgYgLiyxg09JeNVYZziPikBs/X4XqbCG9D0M9yc="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMki6rYwKM+wdjHwqwwobPdt9fknEcMZ5uCNcv79UCiX"
    ];
  };


  security.sudo.wheelNeedsPassword = false;


  ############################# DISPLAY #########################

  # X configuration
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  services.displayManager.autoLogin.user = "john";
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.xfce.enableScreensaver = false;

  #services.xserver.videoDrivers = [ "qxl" ];

########################## PACKAGES ##############################

  # Enable ssh
  services.sshd.enable = true;

  # Included packages here
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    dig
    firefox
    hey
    httpie
    htop
    #google-chrome
    neovim
    wget
    wrk
    git
  ];

  system.stateVersion = "22.11";
}
