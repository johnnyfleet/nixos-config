# Minecraft Bedrock dedicated server (itzg/minecraft-bedrock-server container)
# with an optional restic backup (e.g. to Cloudflare R2 via the S3 API).
#
# The container uses host networking, so the NixOS firewall is the only thing
# deciding who can reach the game port. (Docker/podman port publishing inserts
# its own rules that bypass the host firewall.)
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.minecraftBedrock;
in {
  options.modules.minecraftBedrock = {
    enable = mkEnableOption "Minecraft Bedrock dedicated server";

    image = mkOption {
      type = types.str;
      default = "docker.io/itzg/minecraft-bedrock-server:latest";
      description = "Container image. The image downloads the Bedrock server on start (VERSION env).";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/minecraft-bedrock";
      description = "Host directory mounted at /data (worlds, server.properties, allowlist.json...).";
    };

    port = mkOption {
      type = types.port;
      default = 19132;
      description = "IPv4 game port (UDP).";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open the game port on all interfaces (public internet).";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        Extra environment for the container. See
        https://github.com/itzg/docker-minecraft-bedrock-server#server-properties
      '';
      example = {
        GAMEMODE = "creative";
        ALLOW_LIST_USERS = "PlayerOne,PlayerTwo";
      };
    };

    backup = {
      enable = mkEnableOption "restic backups of the server data directory";

      repository = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "restic repository (use repositoryFile to keep it out of the store).";
      };

      repositoryFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "File containing the restic repository URL.";
      };

      passwordFile = mkOption {
        type = types.str;
        description = "File containing the restic repository password.";
      };

      environmentFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          systemd EnvironmentFile for the backup, e.g. AWS_ACCESS_KEY_ID,
          AWS_SECRET_ACCESS_KEY and optionally HEALTHCHECK_URL (healthchecks.io
          ping URL; /fail is appended on failure).
        '';
      };

      initialize = mkOption {
        type = types.bool;
        default = false;
        description = "Create the repository if it doesn't exist.";
      };

      schedule = mkOption {
        type = types.str;
        default = "00:00";
        description = "systemd OnCalendar expression.";
      };

      pruneOpts = mkOption {
        type = types.listOf types.str;
        default = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--tag automated"
        ];
      };

      exclude = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Paths to exclude (e.g. the re-downloadable bedrock_server-* binaries).";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";

      virtualisation.oci-containers.containers.minecraft-bedrock = {
        image = cfg.image;
        pull = "newer"; # pick up new image versions on restart
        volumes = ["${cfg.dataDir}:/data"];
        environment =
          {
            EULA = "TRUE";
            TZ = config.time.timeZone;
            SERVER_PORT = toString cfg.port;
          }
          // cfg.environment;
        extraOptions = ["--network=host"];
      };

      systemd.tmpfiles.rules = ["d ${cfg.dataDir} 0750 root root -"];

      networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [cfg.port];
    }

    (mkIf cfg.backup.enable {
      services.restic.backups.minecraft = {
        inherit (cfg.backup) repository repositoryFile passwordFile environmentFile initialize pruneOpts exclude;
        paths = [cfg.dataDir];
        extraBackupArgs = [
          "--host ${config.networking.hostName}"
          "--tag automated"
        ];
        timerConfig = {
          OnCalendar = cfg.backup.schedule;
          Persistent = true;
          RandomizedDelaySec = "5m";
        };
      };

      # healthchecks.io ping on success / failure (only if HEALTHCHECK_URL is set).
      systemd.services.restic-backups-minecraft.serviceConfig.ExecStopPost = let
        ping = pkgs.writeShellScript "minecraft-backup-healthcheck" ''
          [ -n "''${HEALTHCHECK_URL:-}" ] || exit 0
          url="$HEALTHCHECK_URL"
          [ "$SERVICE_RESULT" = "success" ] || url="$url/fail"
          ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 -o /dev/null "$url" || true
        '';
      in ["${ping}"];
    })
  ]);
}
