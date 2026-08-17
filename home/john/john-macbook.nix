# Home Manager configuration for the work MacBook Pro (Intel).
#
# Slice 1 scope: the CLI tool set and zsh, matching the Linux hosts as closely as
# macOS allows. Deliberately NOT here yet (see hosts/john-macbook/default.nix):
#   - programs.vscode  - VS Code arrives via Homebrew cask; enabling it here
#                        would install a second, nixpkgs copy.
#   - commit signing   - the Linux hosts sign with ~/.ssh/id_ed25519.pub via the
#                        1Password SSH agent; that agent isn't wired up here yet
#                        (see the programs.ssh note below), so signing is left
#                        off for now. user.name/email are set below though.
#   - programs.ssh     - the 1Password agent socket lives at a different path on
#                        macOS (~/Library/Group Containers/...).
#   - gnupg / sops     - needs pinentry_mac and a host age key.
#
# The 1Password SSH agent's own key list (~/.config/1Password/ssh/agent.toml,
# same path as on the Linux hosts) IS managed below via home.file, since it was
# already being hand-edited on this machine.
{
  pkgs,
  # Passed in from flake.nix (`darwinUser`), the same value used as the
  # home-manager.users key. Not hardcoded, so the two cannot drift apart.
  username,
  ...
}: {
  imports = [
    # Reused verbatim from the Linux hosts. The handful of aliases that differ on
    # macOS are switched on pkgs.stdenv.isDarwin inside that file.
    ./core/zsh/default.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
    flake = "/Users/${username}/.config/nixos-config";
  };

  # Same identity as the Linux hosts (home/john/core/default.nix). No commit
  # signing here yet - see the note at the top of this file.
  programs.git = {
    enable = true;
    settings.user.name = "John Stephenson";
    settings.user.email = "14134347+johnnyfleet@users.noreply.github.com";
    settings.init.defaultBranch = "main";
  };

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

  # Tells the 1Password SSH agent which vault items to expose as SSH keys.
  # Edit this list (or add a `vault = "..."` block with no `item` to pull in
  # every SSH key item from that vault) instead of hand-editing the file on
  # disk - 1Password picks up changes on its next agent restart / the
  # Settings > Developer > "Use the SSH agent" toggle.
  home.file.".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "Main John SSH Key 2023"
    vault = "Private"

    [[ssh-keys]]
    item = "SSH Key - Techwondoe"
    vault = "Private"
  '';
}
