# Nixpkgs overlays applied to ALL hosts.
#
# Keep overlays here (rather than in a single host) so every host and the
# flake `checks` stay consistent - a fix applied only on john-laptop
# previously left john-sony-laptop and `nix flake check` failing.
{...}: {
  nixpkgs.overlays = [
    (import ../../../overlays/default.nix).default
  ];
}
