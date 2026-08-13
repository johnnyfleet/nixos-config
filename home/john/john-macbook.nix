# Home Manager configuration for the work MacBook Pro (Intel).
#
# Slice 1 scope: the CLI tool set and zsh, matching the Linux hosts as closely as
# macOS allows. Deliberately NOT here yet (see hosts/john-macbook/default.nix):
#   - programs.vscode  - VS Code arrives via Homebrew cask; enabling it here
#                        would install a second, nixpkgs copy.
#   - programs.git     - needs the SSH signing key set up first.
#   - programs.ssh     - the 1Password agent socket lives at a different path on
#                        macOS (~/Library/Group Containers/...).
#   - gnupg / sops     - needs pinentry_mac and a host age key.
{pkgs, ...}: let
  # Keep in sync with `username` in hosts/john-macbook/default.nix.
  username = "john";
in {
  imports = [
    # Reused verbatim from the Linux hosts. The handful of aliases that differ on
    # macOS are switched on pkgs.stdenv.isDarwin inside that file.
    ./core/zsh/default.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # The same CLI set the Linux hosts get from
    # hosts/common/core/regular-programs.nix. Installed per-user here because
    # nix-darwin has no equivalent "system packages for everyone" story worth
    # using for these.
    btop # Advanced system utilisation monitor
    dust # Filesystem cli tool
    duf # Fancier version of df
    eza # ls replacement with icons and colour
    fastfetch # Neofetch replacement
    gh # GitHub CLI (formula in brew, but nixpkgs has it for darwin)
    glances # Another monitoring tool
    htop
    jq # JSON parser
    mosh # SSH that survives roaming
    ncdu # Disk usage CLI
    rsync
    wget

    # Not on the Linux hosts yet, but standard enough to want from day one.
    fd
    ripgrep
    tree

    # Required by home/john/core/zsh/default.nix:
    #   devenv -> the `devenv hook zsh` line in initContent
    #   neovim -> $MANPAGER and $EDITOR
    devenv
    neovim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
