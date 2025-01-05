{ config, pkgs, ... }:

{

  # Enable flakpak backend.
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # Enable flathub repo
  environment.etc = {
    "flatpak/remotes.d/flathub.flatpakrepo".source = pkgs.fetchurl {
      url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      # Let this run once and you will get the hash as an error.
      hash = "sha256-M3HdJQ5h2eFjNjAHP+/aFTzUQm9y9K+gwzc64uj+oDo=";
    };
  };

}
