# Home Manager module: read-only rclone mounts of the Kindo dev S3 buckets via AWS SSO.
#
# Usage (in your home config):
#   imports = [ ./kindo-s3.nix ];
#   kindo.s3 = {
#     enable    = true;
#     accountId = "123456789012";
#     roleName  = "YourRoleName";
#   };
#
# Then run `kindo-s3` to sign in (if needed) and mount, `kindo-s3-umount` to unmount.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.kindo.s3;
  bucketList = lib.concatStringsSep " " cfg.buckets;
in {
  options.kindo.s3 = {
    enable = lib.mkEnableOption "Kindo dev S3 access (AWS SSO + rclone read-only mounts)";

    accountId = lib.mkOption {
      type = lib.types.str;
      description = "AWS account ID for the Kindo dev account.";
    };

    roleName = lib.mkOption {
      type = lib.types.str;
      description = "IAM Identity Center role name to use in the dev account.";
    };

    startUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://kindo.awsapps.com/start";
    };

    region = lib.mkOption {
      type = lib.types.str;
      default = "ap-southeast-2";
    };

    profile = lib.mkOption {
      type = lib.types.str;
      default = "kindo-dev";
      description = "Name used for both the AWS CLI profile and the rclone remote.";
    };

    buckets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "kindo-reports-dev"
        "kindo-reports-dry-run-dev"
        "kindo-finance-documents-dev"
      ];
    };

    mountRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/s3";
      description = "Directory under which each bucket is mounted.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.awscli = {
      enable = true;
      settings = {
        "sso-session kindo" = {
          sso_start_url = cfg.startUrl;
          sso_region = cfg.region;
          sso_registration_scopes = "sso:account:access";
        };
        "profile ${cfg.profile}" = {
          sso_session = "kindo";
          sso_account_id = cfg.accountId;
          sso_role_name = cfg.roleName;
          region = cfg.region;
        };
      };
    };

    programs.rclone = {
      enable = true;
      remotes.${cfg.profile}.config = {
        type = "s3";
        provider = "AWS";
        env_auth = true;
        profile = cfg.profile;
        region = cfg.region;
        no_check_bucket = true;
      };
    };

    home.packages = [
      (pkgs.writeShellApplication {
        name = "kindo-s3";
        runtimeInputs = [pkgs.awscli2 pkgs.rclone pkgs.util-linux];
        text = ''
          aws sts get-caller-identity --profile ${cfg.profile} >/dev/null 2>&1 \
            || aws sso login --profile ${cfg.profile}
          for b in ${bucketList}; do
            dir="${cfg.mountRoot}/$b"
            mkdir -p "$dir"
            mountpoint -q "$dir" && continue
            rclone mount "${cfg.profile}:$b" "$dir" \
              --read-only --vfs-cache-mode full --dir-cache-time 1m --daemon
          done
          echo "Mounted under ${cfg.mountRoot}"
        '';
      })
      (pkgs.writeShellApplication {
        name = "kindo-s3-umount";
        text = ''
          for b in ${bucketList}; do
            fusermount3 -u "${cfg.mountRoot}/$b" 2>/dev/null || true
          done
        '';
      })
    ];
  };
}
