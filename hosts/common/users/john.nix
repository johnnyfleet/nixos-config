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
  users.users.john = {
    isNormalUser = true;
    description = "John Stephenson";
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.john-password.path;
    openssh.authorizedKeys.keys =
      let
        authorizedKeys = pkgs.fetchurl {
          url = "https://github.com/johnnyfleet.keys";
          sha256 = "dc858902cef96fe42e620aad6d784736d8db69d6e9cbcea7d55129be4d9fad9d";
        };
      in
      pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
  };

  # Set the default shell as zsh
  programs.zsh.enable = true;
  users.users.john.shell = pkgs.zsh;

}
