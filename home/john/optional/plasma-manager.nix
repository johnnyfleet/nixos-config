{ pkgs, ... }:
{
    #imports = [ <plasma-manager/modules> ];

    programs.plasma = {
        enable = true;

        #
        # Some high-level settings:
        #
        workspace = {
        clickItemTo = "select";
        lookAndFeel = "org.kde.breezedark.desktop";
        cursor.theme = "Bibata-Modern-Ice";
        iconTheme = "Papirus-Dark";
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
        };

        hotkeys.commands."launch-konsole" = {
        name = "Launch Konsole";
        key = "Meta+Alt+K";
        command = "konsole";
        };

        panels = [
            # Windows-like panel at the bottom
            {
                location = "bottom";
                floating = true;
                widgets = [
                {
                    name = "org.kde.plasma.kickoff";
                    config = {
                        General = {
                            icon = "nix-snowflake-white";
                            alphaSort = true;
                        };
                    };
                }
                "org.kde.plasma.icontasks"
                "org.kde.plasma.marginsseparator"
                "org.kde.plasma.systemtray"
                "org.kde.plasma.digitalclock"
                ];
            }
            # Global menu at the top
            {
                location = "top";
                alignment = "center";
                floating = true;
                #hiding = "dodgewindows";
                height = 26;
                widgets = [ "org.kde.plasma.appmenu" ];
            }
        ];
    };

    home.packages = with pkgs; [
        papirus-icon-theme  # Example icon theme
        bibata-cursors # Bibata cursors.
    # Add other icon themes here
    ];
}