# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, secrets, ... }:

{
   # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.john = {
    isNormalUser = true;
    description = "John Stephenson";
    hashedPassword = "${secrets.user.hashedPassword}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Set the default shell as zsh
  programs.zsh.enable = true;
  users.users.john.shell = pkgs.zsh;

}
