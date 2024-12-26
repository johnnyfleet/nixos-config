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

  # Enable 1Password
  home.packages = with pkgs; [
    _1password
    _1password-gui    # GUI application
  ];

  # Optional: Configure 1Password CLI
  programs._1password = {
    enable = true;
  };

  # Optional: Add 1Password SSH agent configuration
  home.file.".ssh/config".text = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';

  # Optional: Enable 1Password browser integration
  programs._1password-gui = {
    enable = true;
    # Enables browser integration
    polkitPolicyOwners = [ "${config.home.username}" ];
  };
}