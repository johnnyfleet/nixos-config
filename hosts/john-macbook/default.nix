# nix-darwin configuration for the work MacBook Pro (Intel, x86_64-darwin).
#
# INSTALLING NIX: use the official installer, NOT the Determinate one. Determinate
# Nix dropped Intel macOS in v3.13.2 (Nov 2025) and errors with "x86_64-darwin not
# found". The official installer also does not enable flakes by default:
#
#   sh <(curl -L https://nixos.org/nix/install) --daemon
#   mkdir -p ~/.config/nix
#   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
#
# Bootstrap (first run only - nix-darwin is not installed yet). Note the 26.05
# ref: running master's darwin-rebuild against this 26.05-pinned config mismatches.
#   sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
#     switch --flake ~/.config/nixos-config#john-macbook
#
# Subsequently:
#   darwin-rebuild switch --flake ~/.config/nixos-config#john-macbook
#   ...or just `suu`, which is aliased to `nh darwin switch` on macOS.
#
# Scope is deliberately small (slice 1): CLI tools, zsh and Homebrew-managed GUI
# apps. No sops, tailscale, git config, GPG/YubiKey or VS Code settings yet.
{
  pkgs,
  inputs,
  # macOS short account name, passed in from flake.nix (`darwinUser`) so that it
  # cannot drift out of sync with the home-manager.users key. Do not hardcode it
  # here - a mismatch makes home.homeDirectory resolve to null.
  username,
  ...
}: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  ############################ USER ###############################

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Required by nix-darwin for anything user-scoped during activation
  # (Homebrew, system.defaults). Without it those silently target the wrong user.
  system.primaryUser = username;

  ############################ NIX ################################

  nixpkgs.hostPlatform = "x86_64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    trusted-users = [
      "root"
      username
    ];
  };

  # Deliberately NOT pointing at the Attic cache on big-john: it only holds
  # x86_64-linux paths, so it would be a guaranteed miss on every fetch.

  # NOTE: on darwin this is a launchd calendar attrset, NOT the `dates = "weekly"`
  # string used by hosts/common/core/gc-optimise.nix on NixOS.
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  ########################### SHELL ###############################

  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];

  # powerlevel10k's glyphs need the font registered with macOS itself. Putting
  # meslo-lgs-nf in home.packages is NOT enough - macOS does not scan
  # ~/.nix-profile/share/fonts. You must still pick the font in your terminal.
  fonts.packages = [pkgs.meslo-lgs-nf];

  ########################## HOMEBREW #############################

  # nix-homebrew installs and owns the Homebrew prefix itself (/usr/local on
  # Intel). This is what removes the manual `curl | bash` bootstrap step.
  nix-homebrew = {
    enable = true;
    user = username;

    # Adopt an existing Homebrew install instead of failing. A work Mac may
    # already have one from IT.
    autoMigrate = true;

    # Let brew manage its own taps. Pinning homebrew-core and homebrew-cask as
    # flake inputs also works, but drags two very large repos into flake.lock
    # and slows `nix flake update` for every other host.
    mutableTaps = true;
  };

  # What Homebrew should install. GUI applications only - CLI tools come from
  # nixpkgs via home-manager so they stay consistent with the Linux hosts.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;

      # "zap" uninstalls anything not listed below. Dangerous on a work machine
      # that may carry IT-installed brew packages - check `brew list` first,
      # then tighten this if you want fully declarative behaviour.
      cleanup = "none";
    };

    casks = [
      "1password"
      "1password-cli"
      "claude-code"
      "claude"
      "github" # GitHub Desktop
      "google-chrome"
      "google-drive"
      "microsoft-office"
      "obsidian"
      "slack"
      "sonos"
      "visual-studio-code"
    ];

    # `gh` is a formula, not a cask - but it is also in nixpkgs for darwin, so it
    # is installed via home-manager instead. Left here as a note in case you
    # would rather brew own it:
    #   brews = ["gh"];
  };

  ########################### SYSTEM ##############################

  networking.computerName = "john-macbook";
  networking.hostName = "john-macbook";

  # Unlike NixOS, this is an integer and is documented in `darwin-rebuild changelog`.
  system.stateVersion = 5;
}
