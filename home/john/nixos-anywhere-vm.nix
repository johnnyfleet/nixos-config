{ configVars, ... }:
{
  imports = [
    #################### Required Configs ####################
    ./core/default.nix # required
    ./optional/plasma-manager.nix # set up of plasma manager on plasma. 
    ./optional/regular-programs.nix # Additional programs I usually have installed
    #./optional/additional-programs.nix # Additional programs I used to have but don't think I need right now. 
    #./optional/gaming.nix # Heroic & Lutris
    #./optional/vm-tools.nix # Useful VM tools (quickemu, virt-sparsify etc.)
    #./optional/dev-tools.nix # direnv, nix-direnv, etc.
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}