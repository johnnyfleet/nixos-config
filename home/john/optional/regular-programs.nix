{ config, pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = [

    # This aims to replicate what I had on john-laptop originally.

    # Base Packages 
    
    
    pkgs.kdePackages.discover
    pkgs.picard
    pkgs.vlc
    pkgs.kdePackages.ghostwriter
    pkgs.spotify
    pkgs.remmina
    pkgs.discord
    pkgs.flameshot

    pkgs.ansible-core # Ansible, duh
    pkgs.ansible-lint # Linting to check playbooks
    pkgs.baobab #Disk Usage Analyser
    pkgs.easytag # Edit MP3 ID3 files
    pkgs.filezilla # FTP client
    pkgs.gnome-keyring # Keyring to access secrets wallet - used for VS code
    #pkgs.gparted # Disk Partition Manager
    pkgs.kdePackages.partitionmanager # Disk Partition Manager
    pkgs.guake # drop-down style terminal

  BASE_PACKAGES:
  - ansible               # this...
  - ansible-lint          # Linting software to check playbooks
  - baobab                # Disk usage analyser
  - easytag               # Edit MP3 id3 files
  - filezilla             # FTP client
  - gnome-keyring         # Keyring to access secrets wallet - used for vscode to store github credentials successfully.
  - gparted               # Disk partition manage
  - guake                 # drop-down style terminal
  - jq                    # JSON parser
  - ncdu                  # Disk usage CLI
  - neofetch              # Nice system info CLI command
  - net-tools             # ipconfig etc.
  - packer                # create VM images
  - picard                # MusicBrainz - music info lookup
  - python3               # Python
  - remmina               # Remote Desktop viewer
  - retext                # Simple markdown editor
  - rpcbind               # Network and RPC program
  - screen                # detached terminal session
  - scribus               # PDF editor (for cd covers)
  - terminator            # Improved shell
  - ufw                   # Uncomplicated firewell
  - vlc                   # VLC media player
  - zsh                   # Z shell

UBUNTU_PACKAGES:
  - alacarte              # Gnome3 menu editor - useful for creating AppImage shortcuts.
  - avahi-daemon          # resolve xxx.local names on network
  - chrome-gnome-shell    # Open links from shell in chrome
  - chromium-browser      # Chromium
  - gir1.2-clutter-1.0    # System tasktray info
  - gir1.2-gtop-2.0       # System tasktray info
  - nfs-kernel-server     # NFS server
  - python3-pip           # Pip installser for Python
  - remmina-plugin-spice  # View SPICE servers (KVM)
  - steam-installer       # Steam installer
  #- docker-ce             # Docker
  #- nextcloud-desktop     # Netcloud client

ARCH_PACKAGES:
  - appimagelauncher      # Makes it easy to install appimage files.
  - arduino               # Arduino IDE
  - aribb24               # Allows VLC to play recordings done via HDHomeRun
  - asciidoctor           # Convert asciidocs to different formats
  - avahi                 # resolve xxx.local names on network
  - audacious             # Music player
  - base-devel            # Fakeroot and other utils needed for AUr installation via Yay
  - bashtop               # Advanced system utilisation monitor (think top, htop)
  - bootsplash-systemd        # Startup splash screen
  - bootsplash-theme-manjaro  # Startup splash screen - Manjaro
  - chezmoi
  - chromium
  - crossover-extras      # Install crossover and dependencies that are required to install windows apps.
  - discord
  - duf                   # Fancier version of df
  - exa                   # alternative to ls which is more colourful and includes icons.
  - dust                  # Filesystem cli tool
  - firefox
  - flameshot             # Screen Snipping tool
  #- fprint                # Fingerprint reader/security - https://www.reddit.com/r/kde/comments/sp1hhh/stepbystep_guide_for_enabling_fingerprint/
  - freerdp
  - gestures              # To get multi finger gestures on touchpad working
  - gimp                  # Image editor.
  - github-cli
  - glances
  - guestfs-tools         # `virt-sparsify and other libvirt tools
  - hplip                 # HP Printer utility
  - htop
  - iucode-tool           # Check intel microcode for updates (dependency on needrestart)
  #- latte-dock            # mac like toolbar for desktop
  #- lastpass-cli          # To interact with lastpass from cli (to help use for ansble-vault)
  - libinput-gestures      # To get multi finger gestures on touchpad working
  - matray                # Manjaro Update tray notifier
  - mosh                  # For connecting over SSH and maintaining session.
  - mutt                  # Email CLI client for reading root mail.
  - needrestart           # Utility to check if a restart is needed post update.
  - neovim                # Vim
  - obsidian              # Note taking app
  - otf-ipafont           # extra fonts for unicode support. Used for Japanese characters.
  - pandoc                # Convert markdown and asciidoc
#  - plasma-wayland-session  # Enables wayland session from the login screen.
  - python-pip            # Pip installser for Python
  - python-pydbus          # Allows script to manage DND mode in KDE. See: https://www.reddit.com/r/kde/comments/t7wj5c/toggle_do_not_disturb_mode_command_line/
  - qmmp                  # winamp like music player
  - sof-firmware          # Fixes sound on Lenovo x1 Carbon Gen 9.
  - speedtest-cli         # Check internet speed from CLI1
  - steam
  - tailscale             # Install tailscale for mesh VPN
  - tlp                   # power management
  - tlpui                 # UI for power management
  - trash-cli             # Simple utility to clean trash but running trash-empty either as user or sudo for root.
  - ttf-font-awesome      # extra fonts for unicode support. Used for icons.
  - unzip
  - yubikey-manager       # To manage YubiKey on device.
  - yubikey-manager-qt    # GUI to managhe Yubikey
  #- yubioath-desktop      # Desktop tool to manage OATH requests via Yubikey. This one doesn't work - replace with flatpak version.

DOCKER_PACKAGES:
  - docker-compose        # Compose

FLATPACK_PACKAGES:
  - org.gnome.gitlab.somas.Apostrophe           # Markdown editor - nice and clean.
  - net.davidotek.pupgui2                       # Helper GUI to install ProtonGE
  - com.yubico.yubioath                         # Yubikey OATH tool
  - com.plexamp.Plexamp                         # Plexamp player
  - com.moonlight_stream.Moonlight              # Moonlight came streaming client



  ];

}