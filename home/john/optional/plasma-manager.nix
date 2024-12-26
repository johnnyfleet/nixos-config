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
                widgets = [
                "org.kde.plasma.kickoff"
                "org.kde.plasma.icontasks"
                "org.kde.plasma.marginsseparator"
                "org.kde.plasma.systemtray"
                "org.kde.plasma.digitalclock"
                ];
            }
            # Global menu at the top
            {
                location = "top";
                height = 26;
                widgets = [ "org.kde.plasma.appmenu" ];
            }
        ];
    };
}