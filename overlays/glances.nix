# Glances overlay - skip tests that require network (localhost connections).
# Remove once nixos-unstable disables these tests upstream.
final: prev: {
  glances = prev.glances.overridePythonAttrs (old: {
    doCheck = false;
  });
}
