{ config, pkgs, ... }:

{

  # Set up bridge network for guests to use
  networking = {
    interfaces.enp0s13f0u3u6.useDHCP = false;  # replace with your real ethernet name
    bridges.br0.interfaces = [ "enp0s13f0u3u6" ];
  };
  networking.interfaces.br0.useDHCP = true;
  
}