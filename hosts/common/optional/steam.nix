{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.steam;
in {
  options.modules.steam = {
    enable = mkEnableOption "Steam gaming platform";

    remotePlay = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall for Steam Remote Play";
    };

    dedicatedServer = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall for Source Dedicated Server";
    };

    localNetworkGameTransfers = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall for Steam Local Network Game Transfers";
    };

    enableWine = mkOption {
      type = types.bool;
      default = true;
      description = "Install Wine for Windows game compatibility";
    };

    enableGameMode = mkOption {
      type = types.bool;
      default = true;
      description = "Install gamemode for performance optimization";
    };
  };

  config = mkIf cfg.enable {
    # Install Steam client
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = cfg.remotePlay;
      dedicatedServer.openFirewall = cfg.dedicatedServer;
      localNetworkGameTransfers.openFirewall = cfg.localNetworkGameTransfers;
    };

    environment.systemPackages = with pkgs;
      [
        libGL
        vulkan-tools
        mesa
      ]
      ++ optionals cfg.enableWine [
        wineWowPackages.staging
        winetricks
      ]
      ++ optionals cfg.enableGameMode [
        gamemode
        mangohud
      ];
  };
}
