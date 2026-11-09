# Overlays directory - exports all overlays as a combined overlay or individually
{
  # Combined overlay that applies all overlays.
  # Currently empty - add short-lived fixes here as `(import ./<name>.nix final prev)`.
  default = final: prev: {};

  # Factory overlay: needs `inputs` to reference the claude-desktop flake source.
  # Usage: `(overlays.claude-desktop inputs)` in nixpkgs.overlays.
  claude-desktop = import ./claude-desktop.nix;
}
