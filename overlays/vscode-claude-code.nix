# Temporary overlay: fix hash mismatch for anthropic.claude-code VS Code extension.
# The upstream VSIX was re-published at the same version (2.1.114), invalidating
# the hash in nixpkgs.  Remove this overlay once nixos-unstable catches up
# (commit 33e124528 or later).
final: prev: {
  vscode-extensions =
    prev.vscode-extensions
    // {
      anthropic =
        prev.vscode-extensions.anthropic
        // {
          claude-code = prev.vscode-extensions.anthropic.claude-code.overrideAttrs (old: {
            src = builtins.fetchurl {
              url = old.src.url;
              sha256 = "sha256-TfVradC9ZjfLBp8QvZ0AptCS9j2ogzSlsRXxksp+N9I=";
            };
          });
        };
    };
}
