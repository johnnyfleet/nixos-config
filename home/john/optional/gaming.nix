{ pkgs, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    heroic # Open source installer for GoG and Epic games.
    protonup-qt # Helper GUI to install ProtonGE
    lutris # Game manager
    moonlight-qt # Moonlight came streaming client
  ];
}
