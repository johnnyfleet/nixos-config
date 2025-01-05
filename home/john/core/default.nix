{
  config,
  lib,
  pkgs,
  outputs,
  configLib,
  sops-nix,
  secrets,
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
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      #henriiik.vscode-sort
      yzhang.markdown-all-in-one
      github.copilot
      github.copilot-chat
      github.vscode-pull-request-github
      eamodio.gitlens
    ];
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "John Stephenson";
    userEmail = "14134347+johnnyfleet@users.noreply.github.com";
  };
}
