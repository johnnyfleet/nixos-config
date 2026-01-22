{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.syncthing;
in {
  options.modules.syncthing = {
    enable = mkEnableOption "Syncthing file synchronization";

    user = mkOption {
      type = types.str;
      description = "User to run Syncthing as";
      example = "john";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/home/${cfg.user}/Syncthing";
      description = "Directory for Syncthing data";
    };

    configDir = mkOption {
      type = types.str;
      default = "/home/${cfg.user}/.config/syncthing";
      description = "Directory for Syncthing configuration";
    };

    openDefaultPorts = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for Syncthing (not GUI)";
    };

    guiUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Username for Syncthing GUI (optional)";
    };

    guiPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Password for Syncthing GUI (optional)";
    };
  };

  config = mkIf cfg.enable {
    # Enable Syncthing. Access through http://127.0.0.1:8384/
    # NOTE: GUI port is not opened in firewall by default
    services.syncthing = {
      enable = true;
      user = cfg.user;
      openDefaultPorts = cfg.openDefaultPorts;
      dataDir = cfg.dataDir;
      configDir = cfg.configDir;

      # Optional: GUI credentials
      settings.gui = mkIf (cfg.guiUser != null && cfg.guiPassword != null) {
        user = cfg.guiUser;
        password = cfg.guiPassword;
      };
    };
  };
}
