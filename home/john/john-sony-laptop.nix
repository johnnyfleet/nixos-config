{ configVars, config, ... }:
{
  imports = [
    #################### Required Configs ####################
    ./core/default.nix # required
    ./optional/plasma-manager.nix # set up of plasma manager on plasma.
    ./optional/regular-programs.nix # Additional programs I usually have installed
    #./optional/additional-programs.nix # Additional programs I used to have but don't think I need right now.
    ./optional/gaming.nix # Heroic & Lutris
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

  xsession.numlock.enable = true;

  sops = {
    #age.keyFile = "/home/user/.age-key.txt"; # must have no password!
    # It's also possible to use a ssh key, but only when it has no password:
    age.sshKeyPaths = [ "/home/john/.ssh/id_ed25519" ];
    defaultSopsFile = ../../secrets/secrets.yaml;

    secrets.git-user-name = {
      key = "git-user-name";
    };
    secrets.git-user-email = {
      key = "git-user-email";
    };
  };
}
