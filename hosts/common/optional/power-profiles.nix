## Applies TLP and thermald to manage laptop power settings.
{pkgs, ...}: {
  services.thermald.enable = true;

  # Disable TLP as it conflicts with power-profiles-daemon
  services.tlp.enable = false;

  services.power-profiles-daemon.enable = true;
}
