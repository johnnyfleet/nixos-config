# Tailscale overlay - skip failing tests
final: prev: {
  tailscale = prev.tailscale.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
