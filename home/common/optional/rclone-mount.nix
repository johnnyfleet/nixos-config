## rclone mount of a cloud remote with a local VFS cache.
##
## Mounts `<remote>:` at `mountPoint` as a systemd user service. Files are
## listed instantly and only downloaded when opened; the cache is bounded by
## `cacheMaxSize` / `--vfs-cache-max-age`.
##
## The rclone config (~/.config/rclone/rclone.conf) is NOT managed here — it is
## created by hand with `rclone config` and must have no config password.
## rclone refreshes the OAuth token and writes it back to that file, so it has
## to stay a writable file rather than a store symlink.
##
## Gotchas:
##   - No conflict handling: last write wins. Don't keep git repos on the mount.
##   - Uncached files are unavailable offline. Pending uploads resume on the
##     next start if the service is stopped mid write-back.
##   - Exclude the mount point and cache dir from any backup tooling. (None is
##     configured in this repo at the time of writing.)
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.rcloneMount;
in {
  options.modules.rcloneMount = {
    enable = mkEnableOption "rclone FUSE mount of a cloud remote with a VFS cache";

    remote = mkOption {
      type = types.str;
      default = "gdrive";
      description = "Name of the remote in rclone.conf (mounted as `<remote>:`).";
    };

    mountPoint = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/GoogleDrive";
      description = "Directory the remote is mounted at. Must be empty or absent.";
    };

    cacheDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/.cache/rclone";
      description = "rclone cache directory (VFS cache lives under `vfs/<remote>`).";
    };

    cacheMaxSize = mkOption {
      type = types.str;
      default = "100G";
      description = "Upper bound for the VFS cache (`--vfs-cache-max-size`).";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["--drive-shared-with-me"];
      description = "Extra arguments appended to `rclone mount`.";
    };

    excludeFromBaloo = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Exclude the mount point from Baloo file indexing (via plasma-manager),
        so the indexer doesn't download the whole remote. Note this makes the
        `exclude folders` key Nix-managed; excludes added in System Settings
        will be overwritten on rebuild.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [pkgs.rclone];

      # Unit named after the remote, e.g. rclone-gdrive.service.
      systemd.user.services."rclone-${cfg.remote}" = {
        Unit = {
          Description = "rclone mount of ${cfg.remote}: at ${cfg.mountPoint}";
          # No-op in the user manager (it can't see system targets), kept as
          # documentation. Startup before the network is up is covered by
          # Restart=on-failure below, which also handles suspend/resume.
          After = ["network-online.target"];
          Wants = ["network-online.target"];
        };

        Service = {
          # rclone mount signals readiness via sd_notify once mounted.
          Type = "notify";
          # fusermount3 is a setuid wrapper, only resolvable from /run/wrappers.
          Environment = ["PATH=/run/wrappers/bin:${makeBinPath [pkgs.coreutils]}"];
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.mountPoint} ${cfg.cacheDir}";
          ExecStart = concatStringsSep " " ([
              "${getExe pkgs.rclone} mount ${cfg.remote}: ${cfg.mountPoint}"
              "--vfs-cache-mode full"
              "--cache-dir ${cfg.cacheDir}"
              "--vfs-cache-max-size ${cfg.cacheMaxSize}"
              "--vfs-cache-max-age 720h"
              "--vfs-write-back 10s"
              "--dir-cache-time 2m"
              "--poll-interval 1m"
              "--contimeout 15s"
              "--timeout 30s"
              # Google Docs/Sheets become .html links that open in the browser,
              # rather than exported .docx copies that never sync back.
              "--drive-export-formats link.html"
            ]
            ++ cfg.extraArgs);
          # Lazy unmount so a busy mount (open shell/Dolphin) doesn't block stop.
          ExecStop = "/run/wrappers/bin/fusermount3 -uz ${cfg.mountPoint}";
          Restart = "on-failure";
          RestartSec = 10;
        };

        Install.WantedBy = ["default.target"];
      };
    }

    (mkIf (cfg.excludeFromBaloo && config.programs.plasma.enable) {
      programs.plasma.configFile.baloofilerc.General."exclude folders" = "${cfg.mountPoint}/";
    })
  ]);
}
