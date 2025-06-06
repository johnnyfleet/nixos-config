# This module adds programs I find useful when using the device for work. 

{ pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  # home.packages = with pkgs; [
  #   bluemail
  # ];

  # Enable thunderbird via programs
  programs.thunderbird = {
    enable = true;

    profiles = {
      "default" = {
        isDefault = true;
        # Optionally you can define settings or use a custom path here
        # path = "~/.thunderbird/default";
      };
    };
  };


}