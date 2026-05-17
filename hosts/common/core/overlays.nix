# Nixpkgs overlays applied to ALL hosts.
#
# Previously this lived only in hosts/john-laptop/default.nix, which left
# john-sony-laptop, vm, and the flake `checks` (which build those configs)
# without the i686 openldap test fix. That made CI fail on the
# john-sony-laptop build and on `nix flake check`, even though local
# john-laptop rebuilds worked. Keep overlays here so every host and the
# flake checks stay consistent.
{...}: {
  nixpkgs.overlays = [
    (import ../../../overlays/default.nix).default
  ];
}
