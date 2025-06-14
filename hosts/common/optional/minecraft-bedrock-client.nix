{ config, pkgs, ... }:
{
  # Install Minecraft bedrock client and open firewall ports for it.
  environment.systemPackages = with pkgs; [
    mcpelauncher-ui-qt
  ];

  networking.firewall.allowedUDPPorts = [ 19132 ];
}
