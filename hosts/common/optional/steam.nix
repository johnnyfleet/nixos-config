{ config, pkgs, ... }:
{
    # Install Steam client and enable remote play.
    program.steam.enable = true;
    program.steam.remotePlay.openFirewall = true;   
}