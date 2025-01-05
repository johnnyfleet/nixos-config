{ config, pkgs, ... }:
{
  # Install Steam client and enable remote play.
  programs.steam = {
    enable = true;
    remotePlay = {
      openFirewall = true;
    };
  };
}
