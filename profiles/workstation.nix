# Workstation profile - development-focused desktop
# Extends desktop with development tools
{
  config,
  lib,
  ...
}: {
  imports = [
    ./desktop.nix # Extends desktop profile
  ];

  # Enable development features on top of desktop
  host.features = {
    gaming = false;
    development = true;
    virtualization = true;
    desktop = true;
    server = false;
    printing = true;
    flatpak = true;
    yubikey = true;
  };
}
