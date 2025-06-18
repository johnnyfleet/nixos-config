# This imports all the standard config that should exist for all machines. 

{ config, pkgs, secrets, ... }:

{
  imports = [
      ./configuration.nix
      ./gc-optimise.nix
      ./regular-programs.nix
      ./yubikey.nix    
      #./desktop-regular-programs.nix

    ];

}
