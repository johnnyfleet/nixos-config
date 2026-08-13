{
  pkgs,
  lib,
  config,
  configVars,
  ...
}: let
  # macOS differences, kept next to the aliases they affect rather than forked
  # into a separate darwin file:
  #   - nix-darwin is driven by `nh darwin`, not `nh os`
  #   - there is no switch-to-configuration, so `sgc` loses its boot-generation half
  #   - the Attic cache on big-john only holds x86_64-linux paths, so pushing
  #     from macOS would be a guaranteed no-op
  # On Linux every alias below evaluates to exactly the string it always was.
  isDarwin = pkgs.stdenv.isDarwin;
  flake = "~/.config/nixos-config";
  nhTarget =
    if isDarwin
    then "darwin"
    else "os";
in {
  home.packages = with pkgs; [
    zsh-powerlevel10k
    meslo-lgs-nf
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      export MANPAGER='nvim +Man!'
      export GROFF_NO_SGR=1
      gem() {
        gemini -p "$*"
      }
      mkcd() { mkdir -p "$1" && cd "$1"; }
      command -v devenv >/dev/null && eval "$(devenv hook zsh)"
    '';

    shellAliases =
      {
        ll = "eza -al --icons --color";
        suu = "nh ${nhTarget} switch ${flake}";
        sru = "nh ${nhTarget} switch github:johnnyfleet/nixos-config --refresh";
        suuu =
          if isDarwin
          then "nix flake update --flake ${flake} && nh darwin switch ${flake}"
          else "nix flake update --flake ${flake} && nh os switch ${flake} && attic push nixos-config /run/current-system";
        sunu = "nix flake update --flake ${flake}";
        gp = "cd ${flake} && git pull";
        sgc =
          if isDarwin
          then "nh clean all --optimise"
          else "nh clean all --optimise && sudo /run/current-system/bin/switch-to-configuration boot";
        nf = "fastfetch";
        ff = "fastfetch";

        sbj = "ssh root@big-john";
        spi = "ssh pi@raspberrypi";
        sp3 = "ssh john@raspberrypi3";
        soc = "ssh ubuntu@minecraft-server";
        sha = "ssh john@homeassistant";

        ts = "tailscale status";
        tu = "sudo tailscale up --exit-node=";
        tuu = "sudo tailscale up --exit-node=big-john";
        td = "sudo tailscale down";
        ni = "sudo nix-index";
        no = "sudo nix store optimise";

        cc = "cd ~/Development/claude-sandbox && claude";
        cm = " claude-monitor --plan pro";
      }
      // lib.optionalAttrs (!isDarwin) {
        # Attic cache holds x86_64-linux paths only - meaningless from macOS.
        ap = "attic push nixos-config /run/current-system";
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
      {
        name = "claude-code";
        file = "claude-code.plugin.zsh";
        src = builtins.fetchGit {
          url = "https://github.com/1160054/claude-code-zsh-completion";
          rev = "639212dbbe9862ed8b8429ef118d05d4d2658fe6";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "robbyrussell";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
  };

  # Integrate nix-index into command-not-found in zsh
  programs.nix-index.enable = true;
  programs.pay-respects.enable = true; # For the "pay respects" command in zsh
}
