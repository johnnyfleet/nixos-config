# Host-level feature flag definitions
# Usage in host config:
#   host.features.gaming = true;
#   host.features.development = true;
{
  config,
  lib,
  ...
}:
with lib; {
  options.host = {
    username = mkOption {
      type = types.str;
      default = "john";
      description = "Primary username for this host";
    };

    features = {
      gaming = mkEnableOption "gaming support (Steam, Wine, gaming tools)";

      development = mkEnableOption "development tools (Docker, dev packages)";

      virtualization = mkEnableOption "virtualization support (libvirt, virt-manager)";

      desktop = mkEnableOption "desktop environment and GUI applications";

      server = mkEnableOption "server-oriented configuration";

      printing = mkEnableOption "printing support (CUPS, drivers)";

      flatpak = mkEnableOption "Flatpak application support";

      yubikey = mkEnableOption "YubiKey hardware key support";
    };
  };

  # Default configuration based on feature flags
  # Note: Actual feature implementation is in features.nix
}
