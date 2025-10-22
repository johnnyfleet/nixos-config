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
    ./gnupg.nix
  ];

  home.username = "john";
  home.homeDirectory =  lib.mkDefault "/home/john";

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

  # Allow 1password to be used as an SSH agent
  programs.ssh = {
    enable = true;
    extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
    '';
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
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

  # Enable kitty terminal
  programs.kitty.enable = true;


}
