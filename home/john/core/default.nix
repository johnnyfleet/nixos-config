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

  # john profile: The option `programs.vscode.extensions' defined in 
  #`/nix/store/3j51n5lyc7fli4w6ic7frvgjdkii1xa5-source/home/john/core/default.nix' 
  # has been renamed to `programs.vscode.profiles.default.extensions'.
  # Enable VSCode
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
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

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    #package = pkgs.neovim;
    vimAlias = true; # Alias vim to nvim
    viAlias = true; # Alias vi to nvim
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      plenary-nvim
      gruvbox-material
      mini-nvim
      nordic-nvim
      render-markdown-nvim
    ];
  };
}
