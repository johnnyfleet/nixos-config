# Home Manager module: read-only rclone mounts of the Kindo dev S3 buckets via AWS SSO.
#
# The account ID and role name are sops secrets, so ~/.aws/config is rendered at boot by
# sops-nix (never in the Nix store) and symlinked here. Usage:
#
#   # NixOS host config:
#   sops.secrets."kindo-s3/aws-account-id".sopsFile = ../../secrets/<host>.yaml;
#   sops.secrets."kindo-s3/aws-role-name".sopsFile = ../../secrets/<host>.yaml;
#   sops.templates."kindo-aws-config" = {
#     owner = "john";
#     content = config.home-manager.users.john.kindo.s3.awsConfigTemplate {
#       accountId = config.sops.placeholder."kindo-s3/aws-account-id";
#       roleName = config.sops.placeholder."kindo-s3/aws-role-name";
#     };
#   };
#
#   # home config:
#   imports = [ ./kindo-s3.nix ];
#   kindo.s3 = {
#     enable = true;
#     awsConfigFile = osConfig.sops.templates."kindo-aws-config".path;
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

    awsConfigFile = lib.mkOption {
      type = lib.types.str;
      example = "/run/secrets/rendered/kindo-aws-config";
      description = ''
        Runtime path of the rendered AWS config (from sops.templates, built with
        awsConfigTemplate). ~/.aws/config is symlinked to it.
      '';
    };

    awsConfigTemplate = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
      description = ''
        Function { accountId, roleName } -> AWS config text. Pass sops placeholders so the
        real values are only substituted at activation time.
      '';
      default = {
        accountId,
        roleName,
      }: ''
        [sso-session kindo]
        sso_start_url = ${cfg.startUrl}
        sso_region = ${cfg.region}
        sso_registration_scopes = sso:account:access

        [profile ${cfg.profile}]
        sso_session = kindo
        sso_account_id = ${accountId}
        sso_role_name = ${roleName}
        region = ${cfg.region}
      '';
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
    # awscli itself, but not programs.awscli.settings - that would put the config in the store.
    programs.awscli.enable = true;
    home.file.".aws/config".source = config.lib.file.mkOutOfStoreSymlink cfg.awsConfigFile;

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
