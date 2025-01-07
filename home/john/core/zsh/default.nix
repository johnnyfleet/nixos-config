{ pkgs, config, configVars, ... }:
{

  home.packages = with pkgs; [ zsh-powerlevel10k meslo-lgs-nf thefuck];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = "
      export MANPAGER='nvim +Man!'
      export GROFF_NO_SGR=1
    ";

    shellAliases = {
      ll = "eza -al --icons --color";
      suu = "nh os switch ~/.config/nixos-config";
      gp = "cd ~/.config/nixos-config && git pull";
      sgc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      nf = "fastfetch";
    };

    plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
	      {
          name = "powerlevel10k-config";
          src = ./p10k;
          file = "p10k.zsh";
        }
        {
          name = "zsh-autosuggestions";
          file = "zsh-autosuggestions.plugin.zsh";
          src = builtins.fetchGit {
            url = "https://github.com/zsh-users/zsh-autosuggestions";
            #rev = "a411ef3e0992d4839f0732ebeb9823024afaaaa8";
            rev = "0e810e5afa27acbd074398eefbe28d13005dbc15";
          };
        }
      ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "robbyrussell";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
  };
}