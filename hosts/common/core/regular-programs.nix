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
    du-dust
    duf
    eza
    fastfetch
    firefox
    gh
    git
    glances
    hey
    htop
    httpie
    jq
    mosh
    ncdu
    neofetch
    #neovim
    nh
    nil # nix language server - for vscode autocomplete
    nixfmt-rfc-style
    sops
    ssh-to-age
    wget
    wrk
  ];

}