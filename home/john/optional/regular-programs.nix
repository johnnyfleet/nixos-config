{ config, pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    # This aims to replicate what I had on john-laptop originally.

    # BASE_PACKAGES: 
    
    
    kdePackages.discover           # KDE store to install flatpak packages
    kdePackages.ghostwriter        # Really good markdown editor, similar to Apostrophe
    spotify                        # Music baby. 

    ansible # Ansible, duh
    ansible-lint # Linting to check playbooks
    baobab #Disk Usage Analyser
    easytag # Edit MP3 ID3 files
    filezilla # FTP client
    gnome-keyring # Keyring to access secrets wallet - used for VS code
    #gparted # Disk Partition Manager
    kdePackages.partitionmanager # Disk Partition Manager
    guake # drop-down style terminal
    jq                    # JSON parser
    ncdu                  # Disk usage CLI
    neofetch              # Nice system info CLI command
    fastfetch          # Neofetch replacement
    nettools             # ipconfig etc.
    packer                # create VM images
    picard                # MusicBrainz - music info lookup
    remmina               # Remote Desktop viewer
    retext                # Simple markdown editor
    rpcbind               # Network and RPC program
    screen                # detached terminal session
    scribus               # PDF editor (for cd covers)
    terminator            # Improved shell
    vlc                   # VLC media player

  # ARCH_PACKAGES:
    #appimagelauncher      # Makes it easy to install appimage files.
    arduino               # Arduino IDE
    aribb24               # Allows VLC to play recordings done via HDHomeRun
    asciidoctor           # Convert asciidocs to different formats
    audacious             # Music player
    #base-devel            # Fakeroot and other utils needed for AUr installation via Yay
    btop               # Advanced system utilisation monitor (think top, htop)
    #bootsplash-systemd        # Startup splash screen
    #bootsplash-theme-manjaro  # Startup splash screen - Manjaro
    chezmoi
    chromium
    #crossover-extras      # Install crossover and dependencies that are required to install windows apps.
    discord
    duf                   # Fancier version of df
    eza                   # alternative to ls which is more colourful and includes icons.
    du-dust                  # Filesystem cli tool
    firefox
    flameshot             # Screen Snipping tool
    freerdp
    #gestures              # To get multi finger gestures on touchpad working
    gimp                  # Image editor.
    gh                # GitHub CLI tool
    glances          # Another monitoring tool
    guestfs-tools         # `virt-sparsify and other libvirt tools
    hplipWithPlugin                 # HP Printer utility
    htop
    iucode-tool           # Check intel microcode for updates (dependency on needrestart)
    libinput-gestures      # To get multi finger gestures on touchpad working
    #matray                # Manjaro Update tray notifier
    mosh                  # For connecting over SSH and maintaining session.
    mutt                  # Email CLI client for reading root mail.
    #needrestart           # Utility to check if a restart is needed post update.
    neovim                # Vim
    obsidian              # Note taking app
    ipafont           # extra fonts for unicode support. Used for Japanese characters.
    pandoc                # Convert markdown and asciidoc
    qmmp                  # winamp like music player
    sof-firmware          # Fixes sound on Lenovo x1 Carbon Gen 9.
    speedtest-cli         # Check internet speed from CLI1
    #tlpui                 # UI for power management
    trash-cli             # Simple utility to clean trash but running trash-empty either as user or sudo for root.
    #ttf-font-awesome      # extra fonts for unicode support. Used for icons.
    unzip
    yubikey-manager       # To manage YubiKey on device.
    yubikey-manager-qt    # GUI to managhe Yubikey
    yubioath-flutter      # Desktop tool to manage OATH requests via Yubikey. This one doesn't work - replace with flatpak version.

  # DOCKER_PACKAGES:
    docker-compose        # Compose
    ctop                 # Top-like interface for containers.

  # FLATPACK_PACKAGES:
    #- org.gnome.gitlab.somas.Apostrophe           # Markdown editor - nice and clean.
    #- net.davidotek.pupgui2                       # Helper GUI to install ProtonGE
    #- com.yubico.yubioath                         # Yubikey OATH tool
    #- com.plexamp.Plexamp                         # Plexamp player
    #- com.moonlight_stream.Moonlight              # Moonlight came streaming client
    apostrophe           # Markdown editor - nice and clean.
    plexamp                         # Plexamp player
    


  # AUR_PACKAGES:
    #- 1password
    #- 1password-cli
    #- autofs                          # for auto mounting NFS shared better on Manjaro.
    #- cloudflared                    # Daemon to manage cloudflare tunnels. Don't use anymore - switched to docker version (plus this seemed to no longer be maintained)
    expressvpn                     # VPN client
    google-chrome
    #- google-drive-ocamlfuse          # FUSE mount to google drive
    insync                         # Cloud drive sync gui tool.
    #- insync-dolphin                 # Integration to file manager
    #- latte-dock-git                  # Latest version of Latte which fixes full screen window issue on Wayland
    #- nohang-git                     # out of memory management.
    microsoft-edge
    #- neovim-symlinks                # Replaces vi & vim with neovim everywhere
    #- noson-app                      # Sonos client program.
    #- pomello                        # Pomodoro Trello Tracking app
    rclone                         # Sync to multiple cloud locations.
    #- xorgxrdp                       # Allow RDP (via xorg) from windows to device
    #- xrdp                           # Allow RDP (via xvnc) fN client
    zoom-us                           # Video conferencing. AUR seems to work better than Flatpak.
    #- gamehub                       # Updated UI to manage games.
    makemkv                       # MakeMKV - DVD/Blue-Ray to MKV formatter.
    mqtt-explorer                 # Allows you to view MQTT messages
    slack
    quickemu                   # Quickly create and run vms. 
    
  ];

  #programs.steam.enable = true;

  #services.tlp.enable = true;

  

}