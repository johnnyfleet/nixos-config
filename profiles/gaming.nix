# Gaming profile - gaming-optimized desktop
# Extends desktop with gaming support
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./desktop.nix # Extends desktop profile
  ];

  # Enable gaming features on top of desktop
  host.features = {
    gaming = true;
    development = false;
    virtualization = false;
    desktop = true;
    server = false;
    printing = true;
    flatpak = true;
    yubikey = true;
  };

  # Gaming-specific kernel optimization (optional)
  # boot.kernelPackages = pkgs.linuxPackages_zen;
}
