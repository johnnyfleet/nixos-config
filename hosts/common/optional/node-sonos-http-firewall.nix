# This file opens up the necessary ports for the Node Sonos HTTP API to discover and control Sonos devices on the network.

{ pkgs, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [ 5005 3500 ];
    allowedUDPPorts = [ 1900 1905 ];
  };

}
