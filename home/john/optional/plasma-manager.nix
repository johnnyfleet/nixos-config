{ pkgs, config, ... }:
{
  #imports = [ <plasma-manager/modules> ];

  home.file.".local/share/icons/trello.svg".source = ../../../icons/trello.svg;
  home.file.".local/share/icons/github.svg".source = ../../../icons/github.svg;

  # Setup timezones in clock/calendar widget. DOESN'T WORK YET as it overwrites the whole file. 
  /* home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
    [Containments][711][Applets][716][Configuration][Appearance]
    selectedTimeZones=America/Los_Angeles,America/Toronto,Local,Europe/London,Asia/Kolkata
  ''; */

  # Shortcuts for launcher
  xdg.desktopEntries = {
    trello = {
      name = "Trello";
      comment = "Open Trello as a Chrome app";
      exec = "${pkgs.google-chrome}/bin/google-chrome-stable --ozone-platform=x11 --profile-directory=Default --class=ChromeAppTrello --app=https://trello.com/b/7Pr30Oly/personal-kanban";
      icon = "/home/${config.home.username}/.local/share/icons/trello.svg";
      categories = [ "Network" "Office" ];
      terminal = false;
      type = "Application";
      settings = {
        StartupWMClass = "ChromeAppTrello";
        X-KDE-WaylandAppId = "ChromeAppTrello";
      };
    };

    github = {
      name = "GitHub";
      comment = "Open GitHub as a Chrome app";
      exec = "${pkgs.google-chrome}/bin/google-chrome-stable --ozone-platform=x11 --profile-directory=Default --class=ChromeAppGitHub --app=https://github.com/";
      icon = "/home/${config.home.username}/.local/share/icons/github.svg";
      categories = [ "Network" "Development" ];
      terminal = false;
      type = "Application";
      settings = {
        StartupWMClass = "ChromeAppGitHub";
        X-KDE-WaylandAppId = "ChromeAppGitHub";
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
                "applications:google-chrome.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:trello.desktop"
                "applications:obsidian.desktop"
                "applications:1password.desktop"                
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
