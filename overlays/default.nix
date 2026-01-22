# Overlays directory - exports all overlays as a combined overlay or individually
{
  # Combined overlay that applies all overlays
  default = final: prev:
    (import ./tailscale.nix final prev)
    // (import ./easytag.nix final prev);

  # Individual overlays for selective use
  tailscale = import ./tailscale.nix;
  easytag = import ./easytag.nix;
}
