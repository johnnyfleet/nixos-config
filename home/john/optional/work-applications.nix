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

  home.packages = with pkgs; [
    # System tray for birdtray, a Thunderbird extension. Set the path to the Thunderbird binary in home-manager.
    (birdtray.overrideAttrs (oldAttrs: {
      cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [ 
        "-DOPT_THUNDERBIRD_CMDLINE=/etc/profiles/per-user/john/bin/thunderbird" 
      ];
    }))
  ]; 

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0"; # Disable Wayland for Thunderbird so it can open and close successfully. 
  };
}