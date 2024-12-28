{ config, pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = [

    # This aims to replicate what I had on john-laptop originally.

    # BASE_PACKAGES: 
    
    
    pkgs.kdePackages.discover           # KDE store to install flatpak packages
    pkgs.kdePackages.ghostwriter        # Really good markdown editor, similar to Apostrophe
    pkgs.spotify                        # Music baby. 

    pkgs.ansible # Ansible, duh
    pkgs.ansible-lint # Linting to check playbooks
    pkgs.baobab #Disk Usage Analyser
    pkgs.easytag # Edit MP3 ID3 files
    pkgs.filezilla # FTP client
    pkgs.gnome-keyring # Keyring to access secrets wallet - used for VS code
    #pkgs.gparted # Disk Partition Manager
    pkgs.kdePackages.partitionmanager # Disk Partition Manager
    pkgs.guake # drop-down style terminal
    pkgs.jq                    # JSON parser
    pkgs.ncdu                  # Disk usage CLI
    pkgs.neofetch              # Nice system info CLI command
    pkgs.fastfetch          # Neofetch replacement
    pkgs.nettools             # ipconfig etc.
    pkgs.packer                # create VM images
    pkgs.picard                # MusicBrainz - music info lookup
    pkgs.remmina               # Remote Desktop viewer
    pkgs.retext                # Simple markdown editor
    pkgs.rpcbind               # Network and RPC program
    pkgs.screen                # detached terminal session
    pkgs.scribus               # PDF editor (for cd covers)
    pkgs.terminator            # Improved shell
    pkgs.vlc                   # VLC media player

  # ARCH_PACKAGES:
    #appimagelauncher      # Makes it easy to install appimage files.
    pkgs.arduino               # Arduino IDE
    pkgs.aribb24               # Allows VLC to play recordings done via HDHomeRun
    pkgs.asciidoctor           # Convert asciidocs to different formats
    pkgs.audacious             # Music player
    #base-devel            # Fakeroot and other utils needed for AUr installation via Yay
    pkgs.btop               # Advanced system utilisation monitor (think top, htop)
    #bootsplash-systemd        # Startup splash screen
    #bootsplash-theme-manjaro  # Startup splash screen - Manjaro
    pkgs.chezmoi
    pkgs.chromium
    #crossover-extras      # Install crossover and dependencies that are required to install windows apps.
    pkgs.discord
    pkgs.duf                   # Fancier version of df
    pkgs.eza                   # alternative to ls which is more colourful and includes icons.
    pkgs.du-dust                  # Filesystem cli tool
    pkgs.firefox
    pkgs.flameshot             # Screen Snipping tool
    pkgs.freerdp
    #gestures              # To get multi finger gestures on touchpad working
    pkgs.gimp                  # Image editor.
    pkgs.gh                # GitHub CLI tool
    pkgs.glances          # Another monitoring tool
    pkgs.guestfs-tools         # `virt-sparsify and other libvirt tools
    pkgs.hplipWithPlugin                 # HP Printer utility
    pkgs.htop
    pkgs.iucode-tool           # Check intel microcode for updates (dependency on needrestart)
    pkgs.libinput-gestures      # To get multi finger gestures on touchpad working
    #matray                # Manjaro Update tray notifier
    pkgs.mosh                  # For connecting over SSH and maintaining session.
    pkgs.mutt                  # Email CLI client for reading root mail.
    #needrestart           # Utility to check if a restart is needed post update.
    pkgs.neovim                # Vim
    pkgs.obsidian              # Note taking app
    pkgs.ipafont           # extra fonts for unicode support. Used for Japanese characters.
    pkgs.pandoc                # Convert markdown and asciidoc
    pkgs.qmmp                  # winamp like music player
    pkgs.sof-firmware          # Fixes sound on Lenovo x1 Carbon Gen 9.
    pkgs.speedtest-cli         # Check internet speed from CLI1
    #tlpui                 # UI for power management
    pkgs.trash-cli             # Simple utility to clean trash but running trash-empty either as user or sudo for root.
    #ttf-font-awesome      # extra fonts for unicode support. Used for icons.
    pkgs.unzip
    pkgs.yubikey-manager       # To manage YubiKey on device.
    pkgs.yubikey-manager-qt    # GUI to managhe Yubikey
    pkgs.yubioath-flutter      # Desktop tool to manage OATH requests via Yubikey. This one doesn't work - replace with flatpak version.

  # DOCKER_PACKAGES:
    pkgs.docker-compose        # Compose

  # FLATPACK_PACKAGES:
    #- org.gnome.gitlab.somas.Apostrophe           # Markdown editor - nice and clean.
    #- net.davidotek.pupgui2                       # Helper GUI to install ProtonGE
    #- com.yubico.yubioath                         # Yubikey OATH tool
    #- com.plexamp.Plexamp                         # Plexamp player
    #- com.moonlight_stream.Moonlight              # Moonlight came streaming client
    pkgs.apostrophe           # Markdown editor - nice and clean.
    pkgs.protonup-qt                       # Helper GUI to install ProtonGE
    pkgs.plexamp                         # Plexamp player
    pkgs.moonlight-qt              # Moonlight came streaming client


  #AUR_PACKAGES:
    - 1password
    - 1password-cli
    #- autofs                          # for auto mounting NFS shared better on Manjaro.
    #- cloudflared                    # Daemon to manage cloudflare tunnels. Don't use anymore - switched to docker version (plus this seemed to no longer be maintained)
    - expressvpn                     # VPN client
    - google-chrome
    #- google-drive-ocamlfuse          # FUSE mount to google drive
    - heroic-games-launcher-electron # Open source installer for GoG and Epic games.
    - insync                         # Cloud drive sync gui tool.
    - insync-dolphin                 # Integration to file manager
    #- latte-dock-git                  # Latest version of Latte which fixes full screen window issue on Wayland
    #- nohang-git                     # out of memory management.
    - microsoft-edge-stable-bin
    - neovim-symlinks                # Replaces vi & vim with neovim everywhere
    #- noson-app                      # Sonos client program.
    #- pomello                        # Pomodoro Trello Tracking app
    - rclone                         # Sync to multiple cloud locations.
    #- xorgxrdp                       # Allow RDP (via xorg) from windows to device
    #- xrdp                           # Allow RDP (via xvnc) fN client
    - zoom                           # Video conferencing. AUR seems to work better than Flatpak.
    #- gamehub                       # Updated UI to manage games.
    #- makemkv                       # MakeMKV - DVD/Blue-Ray to MKV formatter.
    #- mqtt-explorer                 # Allows you to view MQTT messages
    # Slack
    
  ];

  #programs.steam.enable = true;

  #services.tlp.enable = true;

  

}