{
  config,
  lib,
  pkgs,
  outputs,
  configLib,
  ...
}:
{
  #imports = (configLib.scanPaths ./.) ++ (builtins.attrValues outputs.homeManagerModules);
  imports = [
    ./zsh/default.nix
  ];

  home.username = "john";
  home.homeDirectory = "/home/john";

  # Enable VSCode
  programs.vscode = {
    enable = true;
  };
}