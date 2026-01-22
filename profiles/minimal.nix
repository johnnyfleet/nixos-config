# Minimal profile - base system only
# Use for headless servers or minimal installations
{
  config,
  lib,
  ...
}: {
  imports = [
    ../hosts/common/core/default.nix
    ../hosts/common/options.nix
  ];

  # Minimal feature set - all disabled by default
  host.features = {
    gaming = false;
    development = false;
    virtualization = false;
    desktop = false;
    server = true;
    printing = false;
    flatpak = false;
    yubikey = false;
  };
}
