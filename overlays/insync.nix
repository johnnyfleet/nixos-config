# Insync overlay - delete the bundled QtWebEngineProcess.debug before autoPatchelf runs.
# The debug-symbols file has no real data sections, and current patchelf fails on it with
# "data offset extends past file end". The inner insync-pkg derivation isn't exposed, so
# we swap in a stdenvNoCC whose mkDerivation appends a postInstall cleanup step.
# Remove once `nix build nixpkgs#insync` succeeds upstream.
final: prev: {
  insync = prev.insync.override {
    stdenvNoCC =
      prev.stdenvNoCC
      // {
        mkDerivation = args:
          prev.stdenvNoCC.mkDerivation (args
            // {
              postInstall =
                (args.postInstall or "")
                + ''
                  find $out -name '*.debug' -type f -delete
                '';
            });
      };
  };
}
