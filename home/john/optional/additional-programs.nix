# This module includes additional packages that were originally installed on the laptop
# but I don't think are needed anymore. Will lie dormant but can be included to bring all back 

{ config, pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    # BASE_PACKAGES: 
    
    ansible # Ansible, duh
    ansible-lint # Linting to check playbooks
    filezilla # FTP client
    
    gparted # Disk Partition Manager
    guake # drop-down style terminal
    
    packer                # create VM images
    retext                # Simple markdown editor
    rpcbind               # Network and RPC program
    scribus               # PDF editor (for cd covers)
    terminator            # Improved shell
    
    # ARCH_PACKAGES:
    #appimagelauncher      # Makes it easy to install appimage files.
    arduino               # Arduino IDE
    asciidoctor           # Convert asciidocs to different formats
    #base-devel            # Fakeroot and other utils needed for AUr installation via Yay
    #bootsplash-systemd        # Startup splash screen
    #bootsplash-theme-manjaro  # Startup splash screen - Manjaro
    chezmoi
    chromium
    #crossover-extras      # Install crossover and dependencies that are required to install windows apps.
    discord
    freerdp
    #gestures              # To get multi finger gestures on touchpad working
    gimp                  # Image editor.
    #matray                # Manjaro Update tray notifier
    mutt                  # Email CLI client for reading root mail.
    #needrestart           # Utility to check if a restart is needed post update.
    pandoc                # Convert markdown and asciidoc
    qmmp                  # winamp like music player
    #tlpui                 # UI for power management
    #ttf-font-awesome      # extra fonts for unicode support. Used for icons.
    unzip

  # DOCKER_PACKAGES:

  # FLATPACK_PACKAGES:
    #- org.gnome.gitlab.somas.Apostrophe           # Markdown editor - nice and clean.
    #- net.davidotek.pupgui2                       # Helper GUI to install ProtonGE
    #- com.yubico.yubioath                         # Yubikey OATH tool
    #- com.plexamp.Plexamp                         # Plexamp player
    #- com.moonlight_stream.Moonlight              # Moonlight came streaming client
    apostrophe           # Markdown editor - nice and clean.
    


  # AUR_PACKAGES:
    #- 1password
    #- 1password-cli
    #- autofs                          # for auto mounting NFS shared better on Manjaro.
    #- cloudflared                    # Daemon to manage cloudflare tunnels. Don't use anymore - switched to docker version (plus this seemed to no longer be maintained)
    #- google-drive-ocamlfuse          # FUSE mount to google drive
    #- insync-dolphin                 # Integration to file manager
    #- latte-dock-git                  # Latest version of Latte which fixes full screen window issue on Wayland
    #- nohang-git                     # out of memory management.
    #- neovim-symlinks                # Replaces vi & vim with neovim everywhere
    #- noson-app                      # Sonos client program.
    #- pomello                        # Pomodoro Trello Tracking app
    #- xorgxrdp                       # Allow RDP (via xorg) from windows to device
    #- xrdp                           # Allow RDP (via xvnc) fN client
    #- gamehub                       # Updated UI to manage games.
    makemkv                       # MakeMKV - DVD/Blue-Ray to MKV formatter.
    mqtt-explorer                 # Allows you to view MQTT messages
    
  ];

  #programs.steam.enable = true;

  #services.tlp.enable = true;

  

}