{ pkgs, ... }:
{
  #imports = [ <plasma-manager/modules> ];

  # Shortcuts for launcher
  xdg.desktopEntries = {
    trello = {
      name = "Trello";
      comment = "Open Trello as a Chrome app";
      exec = "${pkgs.google-chrome}/bin/google-chrome-stable --profile-directory=Default --class=Trello --app=https://trello.com/";
      # If using Chromium:
      # exec = "${pkgs.chromium}/bin/chromium --profile-directory=Default --class=Trello --app=https://trello.com/";
      icon = "trello";
      categories = [ "Network" "Office" ];
      terminal = false;
      type = "Application";
      settings = {
        StartupWMClass = "Trello";
      };
    };

    github = {
      name = "GitHub";
      comment = "Open GitHub as a Chrome app";
      exec = "${pkgs.google-chrome}/bin/google-chrome-stable --profile-directory=Default --class=GitHub --app=https://github.com/";
      icon = "github";
      categories = [ "Network" "Development" ];
      terminal = false;
      type = "Application";
      settings = {
        StartupWMClass = "GitHub";
      };
    };
  };

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
      #wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Path/contents/images/1920x1080.jpg";
    };

    # Set screen timeout to 10 minutes. 
    kscreenlocker = {
      lockOnResume = true;
      timeout = 10;
    };

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Meta+Alt+K";
      command = "konsole";
    };

    
    shortcuts = {
      # Configure flameshot to use Meta+Shift+S as the shortcut for taking screenshots
      "services/org.flameshot.Flameshot.desktop"."Capture" = "Meta+Shift+S";

    };


    configFile = {
      #  # Override the shortcut in the kglobalshortcutsrc file:
      #  "kglobalshortcutsrc"."services/org.flameshot.Flameshot.desktop"."Capture" = "Meta+Shift+S";
      
      # Launch empty session on reboot
      # "ksmserverrc"."General"."loginMode" = "emptySession";
      
      ksmserver = {
        "General" = {
          "loginMode" = "emptySession";
        };
      };

      # Enable NumLock on startup
      #kcminputrc"."Keyboard"."NumLock" = 0;
      kcminputrc = {
        "Keyboard" = {
          "NumLock" = 0;
        };
      };
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        alignment = "center";
        hiding = "dodgewindows";
        maxLength = 1600;
        minLength = 200;
        floating = true;
        widgets = [
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "applications:code.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:obsidian.desktop"
                "applications:1password.desktop"
                "applications:steam.desktop"
                "applications:firefox.desktop"
                "applications:google-chrome.desktop"

                "applications:trello.desktop"
                "applications:github.desktop"
              ];
            };
            /*
              appearance = {
                  showTooltips = true;
                  highlightWindows = true;
                  indicateAudioStreams = true;
                  fill = true;
              };
            */
          }
          "org.kde.plasma.marginsseparator"
        ];
      }

      # Taskbar at the top
      {
        location = "top";
        alignment = "center";
        floating = true;
        height = 40;
        widgets = [
          # Left-aligned widgets
          {
            name = "org.kde.plasma.kickoff"; # Application menu
            config = {
              General = {
                icon = "nix-snowflake-white";
                alphaSort = true;
              };
            };
          }
          "org.kde.plasma.pager" # Virtual desktop switcher
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
            config = { };
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
    papirus-icon-theme # Example icon theme
    bibata-cursors # Bibata cursors.
    # Add other icon themes here
  ];
}
