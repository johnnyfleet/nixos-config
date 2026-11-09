# Overlays directory - exports all overlays as a combined overlay or individually
{
  # Combined overlay that applies all overlays.
  # Currently empty - add short-lived fixes here as `(import ./<name>.nix final prev)`.
  default = final: prev: {};
}
