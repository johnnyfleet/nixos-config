# Shared regular programs - common desktop applications
# Can be imported by any user's home-manager configuration
{
  pkgs,
  lib,
  ...
}: {
  # Common packages for all users
  home.packages = with pkgs; [
    # Office and productivity
    libreoffice-qt
    hunspell
    hunspellDicts.en_GB-large

    # Media
    aribb24
    audacious
    vlc

    # System utilities
    baobab
    btop
    dust
    duf
    eza
    fastfetch
    htop
    glances
    ncdu
    jq
    nettools
    screen
    trash-cli

    # Browsers
    google-chrome

    # Communication
    slack
    zoom-us

    # Notes and writing
    obsidian
    kdePackages.ghostwriter

    # Remote access
    mosh
    remmina

    # Cloud sync
    rclone
    insync

    # Screenshot
    flameshot

    # Fonts
    ipafont

    # Development tools
    gh
  ];

  programs.firefox.enable = true;

  services.flameshot = {
    enable = true;
    settings.General = {
      contrastOpacity = 188;
      showStartupLaunchMessage = false;
      startupLaunch = true;
    };
  };
}
