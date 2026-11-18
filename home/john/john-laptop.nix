{
  configVars,
  config,
  osConfig,
  ...
}: {
  imports = [
    ##### Core Configuration
    ./core/default.nix # required

    ##### Optional Configuration

    ./optional/plasma-manager.nix # set up of plasma manager on plasma.
    #./optional/niri.nix # Niri wayland compositor setup
    ./optional/regular-programs.nix # Additional programs I usually have installed
    #./optional/additional-programs.nix # Additional programs I used to have but don't think I need right now.
    ./optional/work-applications.nix
    ./optional/gaming.nix # Heroic, Moonlight & Lutris
    ./optional/vm-tools.nix # Useful VM tools (quickemu, virt-sparsify etc.)
    ./optional/dev-tools.nix # direnv, nix-direnv, etc.
    ./optional/obs-studio.nix # OBS Studio setup
    ../common/optional/rclone-mount.nix # Google Drive via rclone mount + VFS cache
    ./optional/kindo-s3.nix #sets up s3 remote mount (via SSO) for Kindo work.
  ];

  # Google Drive at ~/GoogleDrive. rclone.conf (remote `gdrive`) is created by
  # hand with `rclone config` — not managed by Nix.
  modules.rcloneMount.enable = true;

  # Account ID / role name are sops secrets - see the kindo-aws-config template in
  # hosts/john-laptop/default.nix.
  kindo.s3 = {
    enable = true;
    awsConfigFile = osConfig.sops.templates."kindo-aws-config".path;
  };

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
}
