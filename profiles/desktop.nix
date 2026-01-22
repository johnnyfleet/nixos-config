# Desktop profile - standard desktop environment
# Use for everyday desktop usage
{
  config,
  lib,
  ...
}: {
  imports = [
    ../hosts/common/core/default.nix
    ../hosts/common/features.nix
    ../hosts/common/optional/flatpak.nix
    ../hosts/common/optional/printing.nix
  ];

  # Standard desktop features
  host.features = {
    gaming = false;
    development = false;
    virtualization = false;
    desktop = true;
    server = false;
    printing = true;
    flatpak = true;
    yubikey = true;
  };
}
