# Overlays directory - exports all overlays as a combined overlay or individually
{
  # Combined overlay that applies all overlays
  default = final: prev:
    (import ./tailscale.nix final prev)
    // (import ./easytag.nix final prev)
    // (import ./vscode-claude-code.nix final prev)
    // (import ./openldap.nix final prev);

  # Individual overlays for selective use
  tailscale = import ./tailscale.nix;
  easytag = import ./easytag.nix;
  openldap = import ./openldap.nix;

  # Temporary: fix hash mismatch for claude-code VS Code extension
  vscode-claude-code = import ./vscode-claude-code.nix;

  # Factory overlay: needs `inputs` to reference the claude-desktop flake source.
  # Usage: `(overlays.claude-desktop inputs)` in nixpkgs.overlays.
  claude-desktop = import ./claude-desktop.nix;
}
