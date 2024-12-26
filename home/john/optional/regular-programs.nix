{ config, pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = [
    pkgs.filezilla
    pkgs.easytag
    pkgs.kdePackages.partitionmanager
    pkgs.picard
    pkgs.vlc
    pkgs.kdePackages.ghostwriter

  ];

}