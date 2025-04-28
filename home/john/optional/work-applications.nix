# This module adds programs I find useful when using the device for work. 

{ pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    bluemail
  ];

}