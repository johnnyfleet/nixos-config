# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:

{

  ###################### ESSENTIAL CONFIG ########################

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  ############################ NETWORKING ########################

  # Enable networking & tailscale
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client"; # Ensures that exit node functionality works. See: https://discourse.nixos.org/t/tailscale-exit-node-not-working-on-nixos/39897

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

  ############################## LOCALE ############################
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

  # Enablt ntp sync
  services.timesyncd.enable = true;

  ############################# SSH ###############################

  # Enable ssh & fail2ban
  services.sshd.enable = true;
  services.fail2ban.enable = true;

  ############################ SOUND ##############################


  # Enable sound with pipewire.
  #sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  ############################ FONTS ##############################

  # Configure system wide fonts.
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.space-mono
    ];
  };

  ######################## Enable Numlock ##########################
  
  systemd.services.numLockOnTty = {
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    # /run/current-system/sw/bin/setleds -D +num < "$tty";
    ExecStart = lib.mkForce (pkgs.writeShellScript "numLockOnTty" ''
      for tty in /dev/tty{1..6}; do
          ${pkgs.kbd}/bin/setleds -D +num < "$tty";
      done
    '');
  };
};

}
