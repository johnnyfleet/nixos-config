## Alternative to tlp.nix: uses power-profiles-daemon instead of TLP.
## Import this OR tlp.nix, never both.
##
## thermald is deliberately not enabled — see tlp.nix header for why (it exits
## immediately on ThinkPads with DYTC firmware thermal management).
{pkgs, ...}: {
  # Disable TLP as it conflicts with power-profiles-daemon
  services.tlp.enable = false;

  services.power-profiles-daemon.enable = true;
}
