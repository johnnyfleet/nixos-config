# Feature aggregator - wires up feature flags to module configurations
# Import this in your host config along with options.nix to use declarative features
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.host;
  user = cfg.username;
in {
  imports = [
    ./options.nix
    ./optional/docker.nix
    ./optional/syncthing.nix
    ./optional/virtualisation.nix
    ./optional/1password.nix
    ./optional/steam.nix
  ];

  config = {
    # Gaming features
    modules.steam = mkIf cfg.features.gaming {
      enable = true;
    };

    # Development features
    modules.docker = mkIf cfg.features.development {
      enable = true;
      users = [user];
    };

    # Virtualization features
    modules.virtualisation = mkIf cfg.features.virtualization {
      enable = true;
      users = [user];
    };

    # 1Password - enabled when desktop is enabled
    modules._1password = mkIf cfg.features.desktop {
      enable = true;
      polkitPolicyOwners = [user];
    };
  };
}
