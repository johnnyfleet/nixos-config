# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  secrets,
  ...
}:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kiran = {
    isNormalUser = true;
    description = "Kiran Stephenson";
    extraGroups = [ "wheel" ];
    initialHashedPassword = "$6$Teg0qz6p3YqBmUKM$V9Wi0GibAJIxTT4PXcgT2GXBvxhAZJL6hxnSe4/T/gUUitaHleXQeKpyQcaNviReyxPGLIBP/EcMPKBg4VrNM/";
    #hashedPasswordFile = config.sops.secrets.john-password.path;
    
  };

}
