{ pkgs, inputs, system, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    libreoffice-qt # LibreOffice
    hunspell # Spell checker for LibreOffice
    hunspellDicts.en_GB # GB Languages for spell checker
    hunspellDicts.en_NZ # NZ Languages for spell checker
    aribb24 # Allows VLC to play recordings done via HDHomeRun
    audacious # Music player
    baobab # Disk Usage Analyser
    btop # Advanced system utilisation monitor (think top, htop)
    du-dust # Filesystem cli tool
    duf # Fancier version of df
    easytag # Edit MP3 ID3 files
    expressvpn # VPN client
    eza # alternative to ls which is more colourful and includes icons.
    fastfetch # Neofetch replacement
    flameshot # Screen Snipping tool
    gh # GitHub CLI tool
    glances # Another monitoring tool
    gnome-keyring # Keyring to access secrets wallet - used for VS code
    google-chrome
    #hplipWithPlugin # HP Printer utility
    htop
    insync                         # Cloud drive sync gui tool.
    ipafont # extra fonts for unicode support. Used for Japanese characters.
    iucode-tool # Check intel microcode for updates (dependency on needrestart)
    jq # JSON parser
    kdePackages.discover # KDE store to install flatpak packages
    kdePackages.ghostwriter # Really good markdown editor, similar to Apostrophe
    libinput-gestures # To get multi finger gestures on touchpad working
    microsoft-edge
    mosh # For connecting over SSH and maintaining session.
    ncdu # Disk usage CLI
    neofetch # Nice system info CLI command
    #neovim # Vim
    nettools # ipconfig etc.
    obsidian # Note taking app
    packer # create VM images
    plex-desktop # Plex Desktop
    plexamp # Plexamp player
    rclone # Sync to multiple cloud locations.
    remmina # Remote Desktop viewer
    screen # detached terminal session
    slack
    sof-firmware # Fixes sound on Lenovo x1 Carbon Gen 9.
    speedtest-cli # Check internet speed from CLI1
    spotify # Music baby.
    trash-cli # Simple utility to clean trash but running trash-empty either as user or sudo for root.
    vlc # VLC media player
    yubikey-manager # To manage YubiKey on device.
    #yubikey-manager-qt # GUI to managhe Yubikey
    yubioath-flutter # Desktop tool to manage OATH requests via Yubikey. This one doesn't work - replace with flatpak version.
    zoom-us # Video conferencing. AUR seems to work better than Flatpak.
    #inputs.zen-browser.packages."${system}".default

    # DOCKER_PACKAGES:
    docker-compose # Compose
    ctop # Top-like interface for containers.

    # FLATPACK_PACKAGES:
    #- org.gnome.gitlab.somas.Apostrophe           # Markdown editor - nice and clean.
    #- net.davidotek.pupgui2                       # Helper GUI to install ProtonGE
    #- com.yubico.yubioath                         # Yubikey OATH tool
    #- com.plexamp.Plexamp                         # Plexamp player
    #- com.moonlight_stream.Moonlight              # Moonlight came streaming client

  ];

  # See https://github.com/Misterio77/nix-config/blob/main/home/gabriel/features/desktop/common/firefox.nix for tips
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