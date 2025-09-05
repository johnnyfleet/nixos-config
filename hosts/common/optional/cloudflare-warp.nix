{ config, pkgs, ... }:

{


  services.cloudflare-warp.enable = true;
  
  # Install cloudflare-warp
  environment.systemPackages = with pkgs; [
    cloudflare-warp

  ];

}