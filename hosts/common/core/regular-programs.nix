# This file installs most of the regular base packages that
# I would want to use on all machines
{
  config,
  pkgs,
  ...
}: {
  # Included packages here
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    age
    attic-client
    btop
    cifs-utils
    #comma # run programs without installing
    dig
    devenv #developer environment program
    dust
    duf
    eza
    fastfetch
    gh
    git
    glances
    hey
    htop
    httpie
    jq
    mosh
    nano
    ncdu
    nil # nix language server - for vscode autocomplete
    nixfmt
    nix-tree # provides a way to view the size of the nix store.
    rsync
    sops
    ssh-to-age
    sshfs-fuse
    tmux
    wget
    wrk
  ];

  programs.nh = {
    enable = true;
    #clean.enable = true;
    #clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/john/.config/nixos-config"; # sets NH_OS_FLAKE variable for you
  };
}
