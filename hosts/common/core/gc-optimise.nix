# This file sets some of the useful auto optimise functions to periodically
# clean up the nixs-store to free up space. 

{ config, pkgs, ... }:
{
    #Run nix-collect-garbage to clean up old generations.
    nix.gc = {
        automatic = true;
        options = "--delete-older-than 30d";
        dates = "weekly";
    };

    # Optimise the nix store, adding hard links, on a daily timer just after lunch
    nix.optimise = {
        automatic = true;
        dates = ["12:10"];
    };

    # Optimise on every rebuild. 
    #nix.settings.auto-optimise-store = true;

}