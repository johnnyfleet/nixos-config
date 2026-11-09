{
  pkgs,
  inputs,
  ...
}: {
  # Claude Desktop from aaddrick/claude-desktop-debian, which repackages
  # Anthropic's official Linux .deb. The FHS variant exposes docker, node,
  # uv etc. for MCP servers, plus QEMU/OVMF for Cowork VMs.
  nixpkgs.overlays = [inputs.claude-desktop.overlays.default];

  environment.systemPackages = [pkgs.claude-desktop-fhs];
}
