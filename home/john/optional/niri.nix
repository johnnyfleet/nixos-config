{pkgs, ...}: {
  # Home Manager configuration for niri
  # All configuration is session-isolated and uses Nord theme

  # ============================================================================
  # WAYBAR - Top status bar with Nord theme
  # Layout: workspaces (left) | clock (center) | tray, power (right)
  # ============================================================================
  programs.waybar = {
    enable = true;
    # Don't auto-start via systemd - niri handles this via spawn-at-startup
    systemd.enable = false;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        spacing = 4;

        modules-left = ["niri/workspaces" "niri/window"];
        modules-center = ["clock"];
        modules-right = ["pulseaudio" "network" "battery" "tray" "custom/power"];

        "niri/workspaces" = {
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            default = "";
          };
        };

        "niri/window" = {
          format = "{title}";
          max-length = 50;
          separate-outputs = true;
        };

        clock = {
          timezone = "Pacific/Auckland";
          format = "  {:%a %d %b   %H:%M}";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#88c0d0'><b>{}</b></span>";
              days = "<span color='#d8dee9'><b>{}</b></span>";
              weeks = "<span color='#a3be8c'><b>W{}</b></span>";
              weekdays = "<span color='#ebcb8b'><b>{}</b></span>";
              today = "<span color='#bf616a'><b><u>{}</u></b></span>";
            };
          };
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-bluetooth-muted = " {icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };

        network = {
          format-wifi = "{essid} ";
          format-ethernet = "";
          tooltip-format = "{ifname}: {ipaddr}/{cidr} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        tray = {
          spacing = 10;
        };

        "custom/power" = {
          format = "⏻";
          tooltip = false;
          on-click = "~/.config/niri/power-menu.sh";
        };
      };
    };

    # Nord theme styling
    style = ''
      * {
          font-family: "JetBrains Mono Nerd Font", monospace;
          font-size: 13px;
      }

      window#waybar {
          background-color: rgba(46, 52, 64, 0.95);
          border-bottom: 2px solid #4c566a;
          color: #d8dee9;
      }

      button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 0;
      }

      #workspaces button {
          padding: 0 8px;
          background-color: transparent;
          color: #d8dee9;
          border-radius: 4px;
          margin: 4px 2px;
      }

      #workspaces button:hover {
          background: #434c5e;
      }

      #workspaces button.active {
          background-color: #5e81ac;
          color: #eceff4;
      }

      #workspaces button.urgent {
          background-color: #bf616a;
      }

      #window {
          color: #81a1c1;
          padding: 0 10px;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #custom-power {
          padding: 0 12px;
          margin: 4px 2px;
          border-radius: 4px;
          background-color: #3b4252;
          color: #d8dee9;
      }

      #clock {
          background-color: #5e81ac;
          color: #eceff4;
          font-weight: bold;
      }

      #battery {
          background-color: #a3be8c;
          color: #2e3440;
      }

      #battery.charging, #battery.plugged {
          background-color: #a3be8c;
          color: #2e3440;
      }

      #battery.warning:not(.charging) {
          background-color: #ebcb8b;
          color: #2e3440;
      }

      @keyframes blink {
          to {
              background-color: #bf616a;
              color: #eceff4;
          }
      }

      #battery.critical:not(.charging) {
          background-color: #bf616a;
          color: #eceff4;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #network {
          background-color: #88c0d0;
          color: #2e3440;
      }

      #network.disconnected {
          background-color: #bf616a;
          color: #eceff4;
      }

      #pulseaudio {
          background-color: #b48ead;
          color: #2e3440;
      }

      #pulseaudio.muted {
          background-color: #4c566a;
          color: #d8dee9;
      }

      #tray {
          background-color: #3b4252;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #bf616a;
      }

      #custom-power {
          background-color: #bf616a;
          color: #eceff4;
          font-size: 16px;
          padding: 0 14px;
      }

      #custom-power:hover {
          background-color: #d08770;
      }
    '';
  };

  # ============================================================================
  # FUZZEL - Application launcher with Nord theme
  # ============================================================================
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "alacritty";
        layer = "overlay";
        width = 40;
        font = "JetBrains Mono:size=12";
        prompt = "❯ ";
      };
      colors = {
        # Nord theme colors
        background = "2e3440ee";
        text = "d8dee9ff";
        match = "88c0d0ff";
        selection = "4c566aff";
        selection-text = "eceff4ff";
        selection-match = "8fbcbbff";
        border = "5e81acff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };

  # ============================================================================
  # MAKO - Notification daemon with Nord theme
  # IMPORTANT: We do NOT use services.mako.enable because it creates a D-Bus
  # activated service that would auto-start in Plasma sessions.
  # Instead, we write the config manually and let niri start mako explicitly.
  # ============================================================================
  xdg.configFile."mako/config".text = ''
    # Mako notification daemon config - Nord theme
    default-timeout=5000
    border-radius=8
    border-color=#5e81ac
    border-size=2
    padding=15
    width=350
    height=150
    margin=10
    text-color=#eceff4
    background-color=#2e3440
    font=JetBrains Mono 11
    on-button-left=dismiss
    on-button-right=dismiss-all

    [urgency=high]
    border-color=#bf616a
    default-timeout=0

    [urgency=low]
    border-color=#a3be8c
    default-timeout=3000

    [app-name=volume]
    border-color=#b48ead
    default-timeout=1000

    [app-name=brightness]
    border-color=#ebcb8b
    default-timeout=1000
  '';

  # ============================================================================
  # SWAYLOCK - Screen locker with Nord theme
  # ============================================================================
  programs.swaylock = {
    enable = true;
    settings = {
      # Nord polar night
      color = "2e3440";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      # Nord colors for lock indicator
      line-color = "4c566a";
      ring-color = "3b4252";
      inside-color = "2e3440";
      key-hl-color = "88c0d0";
      separator-color = "00000000";
      text-color = "eceff4";
      # Verification state
      inside-ver-color = "5e81ac";
      ring-ver-color = "81a1c1";
      text-ver-color = "eceff4";
      # Wrong password state
      inside-wrong-color = "bf616a";
      ring-wrong-color = "d08770";
      text-wrong-color = "eceff4";
      # Clear state
      inside-clear-color = "ebcb8b";
      ring-clear-color = "d08770";
      text-clear-color = "2e3440";
    };
  };

  # ============================================================================
  # ALACRITTY - Terminal with Nord theme
  # ============================================================================
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.95;
        padding = {
          x = 10;
          y = 10;
        };
      };
      font = {
        normal = {
          family = "JetBrains Mono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold Italic";
        };
        size = 12;
      };
      # Official Nord color scheme
      colors = {
        primary = {
          background = "#2e3440";
          foreground = "#d8dee9";
          dim_foreground = "#a5abb6";
        };
        cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        vi_mode_cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        selection = {
          text = "CellForeground";
          background = "#4c566a";
        };
        search = {
          matches = {
            foreground = "CellBackground";
            background = "#88c0d0";
          };
          focused_match = {
            foreground = "#2e3440";
            background = "#a3be8c";
          };
        };
        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };
        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
        };
        dim = {
          black = "#373e4d";
          red = "#94545d";
          green = "#809575";
          yellow = "#b29e75";
          blue = "#68809a";
          magenta = "#8c738c";
          cyan = "#6d96a5";
          white = "#aeb3bb";
        };
      };
    };
  };

  # ============================================================================
  # GTK CONFIGURATION
  # Instead of using programs.gtk (which conflicts with plasma-manager),
  # we set GTK theme via environment variables. This only affects niri sessions
  # since niri reads these from its spawn environment.
  # ============================================================================

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # These are set in the user's shell environment
  # ============================================================================
  home.sessionVariables = {
    # Wayland support for various toolkits
    NIXOS_OZONE_WL = "1";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # ============================================================================
  # FLAMESHOT - Screenshot tool configured for Wayland/niri
  # ============================================================================
  services.flameshot.settings.General = {
    # Use grim adapter for Wayland compositors (required for niri)
    useGrimAdapter = true;
  };

  # ============================================================================
  # ADDITIONAL PACKAGES for niri desktop experience
  # ============================================================================
  home.packages = with pkgs; [
    # Image viewer
    imv

    # Video player
    mpv

    # PDF viewer
    zathura

    # Archive manager
    file-roller

    # Calculator
    gnome-calculator

    # Text editor
    gnome-text-editor

    # System monitor
    gnome-system-monitor

    # Settings app
    gnome-control-center

    # Power management
    gnome-power-manager

    # Nordic GTK theme
    nordic

    # Nord icon themes
    nordzy-icon-theme
    nordzy-cursor-theme

    # Notification tools
    libnotify
    mako  # Only started by niri, not systemd

    # Power menu helper
    wlogout
  ];

  # ============================================================================
  # POWER MENU FILE - Used by waybar custom power button
  # ============================================================================
  home.file.".config/niri/power-menu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Power menu for fuzzel
      case "$(printf "  Lock\n  Logout\n  Suspend\n⏻  Shutdown\n  Reboot" | fuzzel --dmenu --prompt "Power: ")" in
          "  Lock") swaylock ;;
          "  Logout") niri msg action quit ;;
          "  Suspend") systemctl suspend ;;
          "⏻  Shutdown") systemctl poweroff ;;
          "  Reboot") systemctl reboot ;;
      esac
    '';
  };

  # ============================================================================
  # NIRI CONFIGURATION - Main window manager config with Nord theme
  # ============================================================================
  xdg.configFile."niri/config.kdl".text = ''
    // Niri configuration file
    // Nord themed configuration for niri window manager
    // For more information, see: https://github.com/YaLTeR/niri/wiki/Configuration:-Introduction

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            dwt
            natural-scroll
            accel-speed 0.2
            click-method "clickfinger"
        }

        mouse {
            accel-speed 0.2
        }
    }

    output "eDP-1" {
        scale 1.0
        transform "normal"
        position x=0 y=0
    }

    layout {
        gaps 12

        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        // Nord frost blue for focus ring
        focus-ring {
            width 3
            active-color "#5e81ac"
            inactive-color "#3b4252"
        }

        // Nord themed border
        border {
            width 2
            active-color "#88c0d0"
            inactive-color "#4c566a"
        }
    }

    // Spawn services at startup
    // These only run when niri starts, not in Plasma sessions
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swaybg" "-i" "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Path/contents/images/1920x1080.jpg" "-m" "fill"
    // KDE Wallet for password storage (shared with Plasma)
    spawn-at-startup "kwalletd6"
    // Polkit agent for authentication dialogs (FIDO2, fingerprint, sudo GUI)
    spawn-at-startup "/run/current-system/sw/libexec/polkit-kde-authentication-agent-1"

    // ========================================
    // Auto-start applications
    // ========================================
    // Workspace 1: Slack
    spawn-at-startup "slack"
    // Workspace 1: Trello (Chrome PWA)
    spawn-at-startup "google-chrome-stable" "--profile-directory=Default" "--app=https://trello.com/b/7Pr30Oly/personal-kanban"
    // Workspace 1: Thunderbird
    spawn-at-startup "thunderbird"

    // Set GTK environment for all spawned apps
    environment {
        GTK_THEME "Nordic"
        XCURSOR_THEME "Nordzy-cursors"
        XCURSOR_SIZE "24"
        // 1Password SSH agent
        SSH_AUTH_SOCK "/home/john/.1password/agent.sock"
        // Portal detection for screen sharing (wlr portal)
        XDG_CURRENT_DESKTOP "sway"
    }

    prefer-no-csd

    hotkey-overlay {
        skip-at-startup
    }

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
        slowdown 1.0

        window-open {
            duration-ms 200
            curve "ease-out-expo"
        }

        window-close {
            duration-ms 150
            curve "ease-out-quad"
        }

        horizontal-view-movement {
            duration-ms 200
            curve "ease-out-cubic"
        }

        workspace-switch {
            duration-ms 200
            curve "ease-out-cubic"
        }

        window-movement {
            duration-ms 200
            curve "ease-out-cubic"
        }

        window-resize {
            duration-ms 200
            curve "ease-out-cubic"
        }

        config-notification-open-close {
            duration-ms 200
            curve "ease-out-cubic"
        }
    }

    window-rule {
        match app-id=r#"^org\.gnome\."#
        default-column-width { proportion 0.5; }
    }

    // ========================================
    // Workspace assignments for auto-start apps
    // ========================================

    // Workspace 1: Slack
    window-rule {
        match app-id="Slack"
        open-on-workspace "1"
    }

    // Workspace 1: Trello (Chrome PWA)
    window-rule {
        match app-id="chrome-trello.com__b_7Pr30Oly_personal-kanban-Default"
        open-on-workspace "1"
    }

    // Workspace 1: Thunderbird
    window-rule {
        match app-id="thunderbird"
        open-on-workspace "1"
    }

    binds {
        // Help overlay
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Overview
        Mod+O { toggle-overview; }

        // ========================================
        // Programs
        // ========================================
        Mod+T { spawn "alacritty"; }
        Mod+D { spawn "fuzzel"; }
        // Alt+Space launcher like KDE Plasma
        Alt+Space { spawn "fuzzel"; }
        Super+Alt+L { spawn "swaylock"; }
        // Power menu
        Mod+Shift+P { spawn "sh" "-c" "~/.config/niri/power-menu.sh"; }

        // ========================================
        // Window management
        // ========================================
        Mod+Q { close-window; }

        // Focus movement (vim keys)
        Mod+H       { focus-column-left; }
        Mod+J       { focus-window-down; }
        Mod+K       { focus-window-up; }
        Mod+L       { focus-column-right; }
        Mod+Left    { focus-column-left; }
        Mod+Down    { focus-window-down; }
        Mod+Up      { focus-window-up; }
        Mod+Right   { focus-column-right; }

        // Window movement
        Mod+Ctrl+H      { move-column-left; }
        Mod+Ctrl+J      { move-window-down; }
        Mod+Ctrl+K      { move-window-up; }
        Mod+Ctrl+L      { move-column-right; }
        Mod+Ctrl+Left   { move-column-left; }
        Mod+Ctrl+Down   { move-window-down; }
        Mod+Ctrl+Up     { move-window-up; }
        Mod+Ctrl+Right  { move-column-right; }

        // Monitor focus
        Mod+Shift+H     { focus-monitor-left; }
        Mod+Shift+J     { focus-monitor-down; }
        Mod+Shift+K     { focus-monitor-up; }
        Mod+Shift+L     { focus-monitor-right; }
        Mod+Shift+Left  { focus-monitor-left; }
        Mod+Shift+Down  { focus-monitor-down; }
        Mod+Shift+Up    { focus-monitor-up; }
        Mod+Shift+Right { focus-monitor-right; }

        // Monitor movement
        Mod+Ctrl+Shift+H     { move-column-to-monitor-left; }
        Mod+Ctrl+Shift+J     { move-column-to-monitor-down; }
        Mod+Ctrl+Shift+K     { move-column-to-monitor-up; }
        Mod+Ctrl+Shift+L     { move-column-to-monitor-right; }
        Mod+Ctrl+Shift+Left  { move-column-to-monitor-left; }
        Mod+Ctrl+Shift+Down  { move-column-to-monitor-down; }
        Mod+Ctrl+Shift+Up    { move-column-to-monitor-up; }
        Mod+Ctrl+Shift+Right { move-column-to-monitor-right; }

        // ========================================
        // Workspace management
        // ========================================
        Mod+U           { focus-workspace-down; }
        Mod+I           { focus-workspace-up; }
        Mod+Page_Down   { focus-workspace-down; }
        Mod+Page_Up     { focus-workspace-up; }

        // Move window to workspace
        Mod+Ctrl+U           { move-column-to-workspace-down; }
        Mod+Ctrl+I           { move-column-to-workspace-up; }
        Mod+Ctrl+Page_Down   { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up     { move-column-to-workspace-up; }

        // Move workspace
        Mod+Shift+U           { move-workspace-down; }
        Mod+Shift+I           { move-workspace-up; }
        Mod+Shift+Page_Down   { move-workspace-down; }
        Mod+Shift+Page_Up     { move-workspace-up; }

        // Column management
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // Column width
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+F { maximize-column; }
        Mod+C { center-column; }

        // Resize
        Mod+Minus       { set-column-width "-10%"; }
        Mod+Equal       { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Reset window height
        Mod+Ctrl+R { reset-window-height; }

        // Fullscreen
        Mod+Shift+F { fullscreen-window; }

        // Floating
        Mod+V { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        // ========================================
        // Screenshots
        // ========================================
        Print { screenshot-screen; }
        Alt+Print { screenshot-window; }
        Ctrl+Print { screenshot; }
        // Flameshot (like Plasma's Meta+Shift+S)
        Mod+Shift+S { spawn "flameshot" "gui"; }

        // ========================================
        // Media keys (with OSD notifications)
        // ========================================
        XF86AudioRaiseVolume allow-when-locked=true { spawn "sh" "-c" "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -a volume -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') -h string:x-canonical-private-synchronous:volume 'Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\""; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "sh" "-c" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -a volume -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') -h string:x-canonical-private-synchronous:volume 'Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%\""; }
        XF86AudioMute        allow-when-locked=true { spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -a volume -h string:x-canonical-private-synchronous:volume 'Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 'Muted' || echo 'Unmuted')\""; }
        XF86AudioMicMute     allow-when-locked=true { spawn "sh" "-c" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify-send -a volume -h string:x-canonical-private-synchronous:volume 'Microphone' \"$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo 'Muted' || echo 'Unmuted')\""; }

        // Brightness control (with OSD notifications)
        XF86MonBrightnessUp   allow-when-locked=true { spawn "sh" "-c" "brightnessctl set 5%+ && notify-send -a brightness -h int:value:$(brightnessctl -m | cut -d, -f4 | tr -d '%') -h string:x-canonical-private-synchronous:brightness 'Brightness' \"$(brightnessctl -m | cut -d, -f4)\""; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "sh" "-c" "brightnessctl set 5%- && notify-send -a brightness -h int:value:$(brightnessctl -m | cut -d, -f4 | tr -d '%') -h string:x-canonical-private-synchronous:brightness 'Brightness' \"$(brightnessctl -m | cut -d, -f4)\""; }

        // ========================================
        // System
        // ========================================
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        // ========================================
        // Workspace number keys
        // ========================================
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+0 { focus-workspace 10; }

        // Move window to numbered workspace
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }
        Mod+Ctrl+0 { move-column-to-workspace 10; }
    }

    debug {
        preview-render "screencast"
    }
  '';
}
