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
        iconTheme = "breeze-dark";
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
                alignment = "center";
                hiding = "dodgewindows";
                maxLength = 1600;
                minLength = 500;
                floating = true;
                widgets = [
                    {
                        name = "org.kde.plasma.icontasks";
                        config = {
                            General.launchers = [
                            "applications:code.desktop"
                            "applications:org.kde.dolphin.desktop"
                            "applications:org.kde.konsole.desktop"
                            "applications:org.kde.webbrowser.desktop"
                            "applications:obsidian.desktop"
                            ];
                       /*  };
                        appearance = {
                            showTooltips = true;
                            highlightWindows = true;
                            indicateAudioStreams = true;
                            fill = true; */
                        };
                    }
                    "org.kde.plasma.marginsseparator"
                ];
            }

            # Taskbar at the top
            {
                location = "top";
                alignment = "center";
                floating = true;
                height = 40 ;
                widgets = [
                    # Left-aligned widgets

                    "org.kde.plasma.pager" # Virtual desktop switcher
                    {
                    name = "org.kde.plasma.kickoff"; # Application menu
                    config = {
                        General = {
                            icon = "nix-snowflake-white";
                            alphaSort = true;
                        };
                    };
                    }
                    "org.kde.plasma.appmenu"
                    "org.kde.plasma.panelspacer"
    
            
                    
                    # Center-aligned widgets
                    {
                    name = "org.kde.plasma.digitalclock"; # Digital clock
                    config = {
                        showDate = true; # Example setting (optional)
                        };
                    }
                    "org.kde.plasma.panelspacer"
                    
                    # Right-aligned widgets
                    "org.kde.plasma.systemmonitor.cpu"
                    "org.kde.plasma.systemmonitor.memory"
                    {
                    name = "org.kde.plasma.systemtray"; # System tray
                    config = {};
                    }
                    {
                        name = "org.kde.plasma.lock_logout";
                        config = {
                            General = {
                                show_lockScreen = "false";
                                show_requestLogoutScreen = "true";
                                show_requestReboot = "true";
                                show_requestShutDown = "true";
                            };
                        };
                    }
                ];
            }

        ];
    };

    home.packages = with pkgs; [
        papirus-icon-theme  # Example icon theme
        bibata-cursors # Bibata cursors.
    # Add other icon themes here
    ];
}