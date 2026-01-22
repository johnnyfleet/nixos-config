{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.docker;
in {
  options.modules.docker = {
    enable = mkEnableOption "Docker container runtime";

    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users to add to the docker group";
      example = ["john" "alice"];
    };

    enableOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Start Docker daemon on boot";
    };

    rootless = mkOption {
      type = types.bool;
      default = false;
      description = "Enable rootless Docker mode";
    };
  };

  config = mkIf cfg.enable {
    # Enable Docker
    virtualisation.docker = {
      enable = true;
      enableOnBoot = cfg.enableOnBoot;

      # Rootless mode configuration
      rootless = mkIf cfg.rootless {
        enable = true;
        setSocketVariable = true;
      };
    };

    # Add specified users to the docker group
    users.users = genAttrs cfg.users (user: {
      extraGroups = ["docker"];
    });

    # Add extra tools
    environment.systemPackages = with pkgs; [
      ctop # Top-like interface for containers
      docker-compose # Docker Compose
    ];
  };
}
