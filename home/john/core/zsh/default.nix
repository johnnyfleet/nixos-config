{
  pkgs,
  config,
  configVars,
  ...
}: {
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

      # Panic unmute for the MuteMe button (hosts/common/optional/muteme.nix).
      # The button mutes PipeWire capture streams, so with the device left at
      # home there is no way to undo that from the hardware. This clears mute
      # on every capture node - both hardware sources and per-app streams -
      # so it recovers whether the mute landed on the device or on Chrome's
      # stream. No argument means unmute: that is the in-a-call case.
      #
      # ''${=ids} is deliberate: zsh does not word-split unquoted expansions,
      # so a plain $ids passes "55\n56" as a single argument and every wpctl
      # call fails. Errors are surfaced rather than swallowed - a rescue
      # command that quietly does nothing is worse than one that complains.
      mic() {
        local ids id
        ids=$(pw-dump | jq -r '.[] | select(.type=="PipeWire:Interface:Node") | select(.info.props["media.class"]=="Audio/Source" or .info.props["media.class"]=="Stream/Input/Audio") | .id')
        case "$1" in
          off|mute)
            for id in ''${=ids}; do wpctl set-mute $id 1 || return 1; done
            echo "mic: MUTED"
            ;;
          status)
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@
            ;;
          *)
            for id in ''${=ids}; do wpctl set-mute $id 0 || return 1; done
            echo "mic: UNMUTED"
            ;;
        esac
      }

      eval "$(devenv hook zsh)"
    '';

    shellAliases = {
      ll = "eza -al --icons --color";
      suu = "nh os switch ~/.config/nixos-config";
      sru = "nh os switch github:johnnyfleet/nixos-config --refresh";
      suuu = "nix flake update --flake ~/.config/nixos-config && nh os switch ~/.config/nixos-config && attic push nixos-config /run/current-system";
      sunu = "nix flake update --flake ~/.config/nixos-config";
      gp = "cd ~/.config/nixos-config && git pull";
      sgc = "nh clean all --optimise && sudo /run/current-system/bin/switch-to-configuration boot";
      nf = "fastfetch";
      ff = "fastfetch";
      ap = "attic push nixos-config /run/current-system";
      nt = "nix-tree -- /nix/var/nix/profiles/system-*";
      lg = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";

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

      smbk = "pkill -f 'kf6/kio/smb.so' && pkill -f smbnotifier && pkill -f kiod6";

      # Mic rescue - see the mic() function above. mu = unmute (the one to
      # remember mid-call), mm = mute, ms = show current state.
      mu = "mic on";
      mm = "mic off";
      ms = "mic status";
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
