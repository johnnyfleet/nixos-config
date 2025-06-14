# Setup dev tools like direnv to make it easier for local development. 
{ pkgs, inputs, system, ... }:
{
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}