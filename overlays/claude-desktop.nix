# Claude Desktop overlay - builds k3d3/claude-desktop-linux-flake against
# our nixpkgs, working around upstream's reference to `nodePackages.asar`
# (removed from recent nixos-unstable — `asar` is now top-level).
#
# This is a factory overlay: it takes `inputs` and returns an overlay.
inputs: final: prev: let
  src = inputs.claude-desktop;

  patchy-cnb = final.callPackage "${src}/pkgs/patchy-cnb.nix" {};

  claude-desktop = final.callPackage "${src}/pkgs/claude-desktop.nix" {
    inherit patchy-cnb;
    # Shim: `asar` was moved out of `nodePackages` in recent nixpkgs, and
    # `prev.nodePackages` itself now throws on access — so provide a fresh
    # attrset with just the one attribute upstream actually consumes.
    nodePackages = {asar = final.asar;};
  };
in {
  inherit claude-desktop;

  claude-desktop-with-fhs = final.buildFHSEnv {
    name = "claude-desktop";
    targetPkgs = pkgs:
      with pkgs; [
        docker
        glibc
        openssl
        nodejs
        uv
      ];
    runScript = "${claude-desktop}/bin/claude-desktop";
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${claude-desktop}/share/applications/claude.desktop $out/share/applications/
      mkdir -p $out/share/icons
      cp -r ${claude-desktop}/share/icons/* $out/share/icons/
    '';
  };
}
