# Server profile - headless server configuration
# Use for servers and VMs without GUI
{
  config,
  lib,
  ...
}: {
  imports = [
    ../hosts/common/core/default.nix
    ../hosts/common/features.nix
  ];

  # Server-oriented features
  host.features = {
    gaming = false;
    development = true; # Docker for container workloads
    virtualization = false;
    desktop = false;
    server = true;
    printing = false;
    flatpak = false;
    yubikey = false;
  };

  # Server-specific settings
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
}
