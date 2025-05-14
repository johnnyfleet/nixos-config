# This file installs most of the regular desktop packages that
# I would want to use on all machines which run a desktop

{ config, pkgs, ... }:
{

   # Included packages here
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    firefox
    whatsapp-for-linux
    vdhcoapp # Companion application for the Video DownloadHelper browser add-on
  ];



}