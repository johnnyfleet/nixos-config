# This module adds programs I find useful when using the device for work.
{pkgs, ...}: let
  # Markdown Here Revival is not in nixpkgs, so package the xpi into the layout
  # home-manager's thunderbird module expects: the add-on's gecko id under
  # share/mozilla/extensions/{ec8030f7-...}.
  markdown-here-revival = pkgs.stdenvNoCC.mkDerivation {
    pname = "thunderbird-markdown-here-revival";
    version = "3.0.2";

    src = pkgs.fetchurl {
      url = "https://addons.thunderbird.net/thunderbird/downloads/file/1018457/markdown_here_revival-3.0.2-tb.xpi";
      hash = "sha256-OM7QlEZoYPXYi7WCFh8/fKzn19gUa/sW0lN5HLB4CN8=";
    };

    dontUnpack = true;

    installPhase = ''
      dir="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
      mkdir -p "$dir"
      install -m444 "$src" "$dir/markdown-here-revival@xul.calypsoblue.org.xpi"
    '';
  };
in {
  # Packages that should be installed to the user profile.
  # home.packages = with pkgs; [
  #   bluemail
  # ];

  # Enable thunderbird via programs
  programs.thunderbird = {
    enable = true;

    profiles = {
      "default" = {
        isDefault = true;
        # Optionally you can define settings or use a custom path here
        # path = "~/.thunderbird/default";
        extensions = [markdown-here-revival];
        settings = {
          # Auto-enable Nix-installed add-ons instead of enabling them by hand.
          "extensions.autoDisableScopes" = 0;
        };
      };
    };
  };

  home.packages = with pkgs; [
    # System tray for birdtray, a Thunderbird extension. Set the path to the Thunderbird binary in home-manager.
    (birdtray.overrideAttrs (oldAttrs: {
      cmakeFlags =
        (oldAttrs.cmakeFlags or [])
        ++ [
          "-DOPT_THUNDERBIRD_CMDLINE=/etc/profiles/per-user/john/bin/thunderbird"
        ];
    }))
    ganttproject-bin
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0"; # Disable Wayland for Thunderbird so it can open and close successfully.
  };
}
