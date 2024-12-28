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


  ];

}