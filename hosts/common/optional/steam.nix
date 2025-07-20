{ config, pkgs, ... }:
{
  # Install Steam client and enable remote play.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers  };
  };

  environment.systemPackages = with pkgs; [
    wineWowPackages.staging
    winetricks
    gamemode
    mangohud
    libGL
    vulkan-tools
    mesa
  # Optional: lutris if you want more control
  ];

}
