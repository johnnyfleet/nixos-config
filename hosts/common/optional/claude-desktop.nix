{
  pkgs,
  inputs,
  ...
}: {
  # Register the overlay that builds claude-desktop against our nixpkgs
  # (works around upstream's reference to the removed `nodePackages.asar`).
  nixpkgs.overlays = [
    ((import ../../../overlays/default.nix).claude-desktop inputs)
  ];

  environment.systemPackages = [pkgs.claude-desktop-with-fhs];
}
