# Minecraft Bedrock server - Oracle Cloud (Ampere A1, aarch64), replacing the
# Ubuntu 22.04 box. See ./README.md for testing, secrets and migration.
#
# Local test VM (x86_64, no secrets needed, backups go to a local repo):
#   nix build .#nixosConfigurations.minecraft-server.config.system.build.vm
#   ./result/bin/run-minecraft-server-vm
#   ssh -p 2222 john@localhost      # game on localhost:19132/udp
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  testVm = config.minecraftServer.testVm;
in {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    # Only the server-appropriate parts of core (core/configuration.nix pulls
    # in pipewire, fonts, networkmanager and opens 22/tcp publicly).
    ../common/core/gc-optimise.nix
    ../common/core/overlays.nix
    ../common/core/sops.nix

    ../common/users/john.nix

    ../common/optional/minecraft-bedrock-server.nix
  ];

  options.minecraftServer.testVm = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set inside virtualisation.vmVariant: swaps secrets/R2/tailscale auth for local stand-ins.";
  };

  config = lib.mkMerge [
    {
      ######################### MINECRAFT ##########################

      modules.minecraftBedrock = {
        enable = true;
        # Mirrors the old docker-compose.yml. Everything else lives in
        # server.properties inside the data dir (restored from backup).
        environment = {
          VERSION = "LATEST";
          GAMEMODE = "creative";
          LEVEL_TYPE = "default";
          ALLOW_CHEATS = "true";
          ALLOW_LIST = "true"; # keeps the existing allowlist.json in the data dir
          # Fresh 1.26.x installs default to transport=nethernet, which doesn't
          # listen for RakNet on 19132 (tested in the VM). Pin the classic transport
          # so clients connecting by IP:port keep working.
          TRANSPORT = "raknet";
        };

        backup = {
          enable = true;
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--tag automated"
          ];
        };
      };

      ######################### NETWORK / FIREWALL #################
      # Matches the ufw rules on the Ubuntu box:
      #   tailscale0: allow everything   public: 19132/udp only (no public SSH)

      networking.hostName = "minecraft-server";
      networking.nftables.enable = true;
      networking.firewall = {
        enable = true;
        trustedInterfaces = ["tailscale0"];
        allowedUDPPorts = [config.services.tailscale.port];
        # 19132/udp is opened by modules.minecraftBedrock.openFirewall
      };

      services.tailscale.enable = true;

      ######################### SSH ##############################

      services.openssh = {
        enable = true;
        openFirewall = false; # reachable over tailscale only
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      services.fail2ban.enable = true;

      # Key-only box, same as the Ubuntu `ubuntu` user (NOPASSWD sudo).
      security.sudo.wheelNeedsPassword = false;

      ######################### SYSTEM ###########################

      time.timeZone = "Pacific/Auckland";
      i18n.defaultLocale = "en_GB.UTF-8";

      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root" "john"]; # allows remote nixos-rebuild --target-host
      };
      nixpkgs.config.allowUnfree = true;

      # 6 GB RAM and no swap on the Ubuntu box - give the bedrock server some headroom.
      zramSwap.enable = true;

      environment.systemPackages = with pkgs; [
        btop
        curl
        duf
        git
        htop
        mosh # firewall: only reachable via tailscale (trusted interface)
        ncdu
        neovim
        restic
        tmux
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      system.stateVersion = "25.05";
    }

    ######################### PRODUCTION SECRETS (sops) ###########
    (lib.mkIf (!testVm) {
      # Host-only secrets (see docs/sops.md). Edit with: sops secrets/minecraft-server.yaml
      sops.defaultSopsFile = ../../secrets/minecraft-server.yaml;
      sops.secrets."minecraft-server/restic-repository" = {};
      sops.secrets."minecraft-server/restic-password" = {};
      sops.secrets."minecraft-server/restic-env" = {}; # AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / HEALTHCHECK_URL
      sops.secrets."minecraft-server/tailscale-authkey" = {};

      modules.minecraftBedrock.backup = {
        repositoryFile = config.sops.secrets."minecraft-server/restic-repository".path;
        passwordFile = config.sops.secrets."minecraft-server/restic-password".path;
        environmentFile = config.sops.secrets."minecraft-server/restic-env".path;
      };

      # Only used for first login; afterwards the node state in /var/lib/tailscale is kept.
      services.tailscale.authKeyFile = config.sops.secrets."minecraft-server/tailscale-authkey".path;
    })

    ######################### LOCAL TEST VM #######################
    (lib.mkIf testVm {
      modules.minecraftBedrock.backup = {
        repository = "/var/backup/restic-minecraft";
        passwordFile = toString (pkgs.writeText "restic-test-password" "test-only-not-a-secret");
        initialize = true;
      };
      # Port-forwarded SSH arrives on eth0, not tailscale0.
      services.openssh.openFirewall = lib.mkForce true;
    })

    {
      virtualisation.vmVariant = {
        minecraftServer.testVm = true;
        nixpkgs.hostPlatform = lib.mkForce "x86_64-linux"; # build/run natively on the laptop
        virtualisation = {
          graphics = false; # serial console in the terminal
          cores = 2;
          memorySize = 4096;
          diskSize = 10240; # MB - image + server binaries + world
          forwardPorts = [
            {
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }
            {
              from = "host";
              proto = "udp";
              host.port = 19132;
              guest.port = 19132;
            }
          ];
        };
      };
    }
  ];
}
