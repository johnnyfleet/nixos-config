{ config, pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    # This aims to replicate what I had on john-laptop originally.

    # BASE_PACKAGES: 
    
    
    kdePackages.discover           # KDE store to install flatpak packages
    kdePackages.ghostwriter        # Really good markdown editor, similar to Apostrophe
    spotify                        # Music baby. 

    baobab #Disk Usage Analyser
    easytag # Edit MP3 ID3 files
    gnome-keyring # Keyring to access secrets wallet - used for VS code
    kdePackages.partitionmanager # Disk Partition Manager
    jq                    # JSON parser
    ncdu                  # Disk usage CLI
    neofetch              # Nice system info CLI command
    fastfetch          # Neofetch replacement
    nettools             # ipconfig etc.
    packer                # create VM images
    remmina               # Remote Desktop viewer
    screen                # detached terminal session
    vlc                   # VLC media player

  # ARCH_PACKAGES:
    #appimagelauncher      # Makes it easy to install appimage files.
    aribb24               # Allows VLC to play recordings done via HDHomeRun
    audacious             # Music player
    btop               # Advanced system utilisation monitor (think top, htop)
    duf                   # Fancier version of df
    eza                   # alternative to ls which is more colourful and includes icons.
    du-dust                  # Filesystem cli tool
    firefox
    flameshot             # Screen Snipping tool
    gh                # GitHub CLI tool
    glances          # Another monitoring tool
    guestfs-tools         # `virt-sparsify and other libvirt tools
    hplipWithPlugin                 # HP Printer utility
    htop
    iucode-tool           # Check intel microcode for updates (dependency on needrestart)
    libinput-gestures      # To get multi finger gestures on touchpad working
    mosh                  # For connecting over SSH and maintaining session.
    neovim                # Vim
    obsidian              # Note taking app
    ipafont           # extra fonts for unicode support. Used for Japanese characters.
    sof-firmware          # Fixes sound on Lenovo x1 Carbon Gen 9.
    speedtest-cli         # Check internet speed from CLI1
    trash-cli             # Simple utility to clean trash but running trash-empty either as user or sudo for root.
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
    slack
    quickemu                   # Quickly create and run vms. 
    
  ];

  #programs.steam.enable = true;

  #services.tlp.enable = true;

  

}