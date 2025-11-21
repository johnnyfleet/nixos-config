# This file installs most of the regular base packages that
# I would want to use on all machines

{ config, pkgs, ... }:
{

  # Included packages here
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    age
    btop
    cifs-utils
    #comma # run programs without installing
    dig
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
    neofetch
    nixfmt-rfc-style
    #neovim
    nh
    nil # nix language server - for vscode autocomplete
    nixfmt-rfc-style
    nix-tree # provides a way to view the size of the nix store. 
    rsync
    sops
    ssh-to-age
    tmux
    wget
    wrk
  ];

}