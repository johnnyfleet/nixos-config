{ pkgs, ... }:

{
  # Home Manager configuration for niri
  
  # Configure waybar for niri
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];
        
        "niri/workspaces" = {
          all-outputs = true;
          format = "{name}";
        };
        
        "niri/window" = {
          format = "{title}";
          max-length = 50;
          separate-outputs = true;
        };
        
        clock = {
          timezone = "Pacific/Auckland";
          format = "{:%Y-%m-%d %H:%M}";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };
        
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        
        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
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
          format-icons = [ "" "" "" "" "" ];
        };
        
        tray = {
          spacing = 10;
        };
      };
    };
    
    style = ''
      * {
          font-family: "JetBrains Mono Nerd Font", monospace;
          font-size: 13px;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.9);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
      }

      button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 0;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.active {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpd {
          padding: 0 10px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      #clock {
          background-color: #64727D;
      }

      #battery {
          background-color: #ffffff;
          color: #000000;
      }

      #battery.charging, #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #network {
          background-color: #2980b9;
      }

      #network.disconnected {
          background-color: #f53c3c;
      }

      #pulseaudio {
          background-color: #f1c40f;
          color: #000000;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }
    '';
  };

  # Configure fuzzel application launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "alacritty";
        layer = "overlay";
        width = 40;
        font = "JetBrains Mono:size=12";
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        match = "f38ba8ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "f38ba8ff";
        border = "b4befeff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  # Configure mako notification daemon
  services.mako = {
    enable = true;   
    
    settings = {
      default-timeout = 5000;
      border-radius = 10;
      border-color = "#89b4fa";
      border-size = 2;
      padding = "15";
      width = 350;
      height = 150;
      margin = "10";  
      text-color = "#cdd6f4";
      background-color = "#1e1e2e";
      font = "JetBrains Mono 11";
    };
    
    extraConfig = ''
      [urgency=high]
      border-color=#f38ba8
      default-timeout=0

      [app-name=volume]
      border-color=#fab387
      default-timeout=1000

      [app-name=brightness]
      border-color=#f9e2af
      default-timeout=1000
    '';
  };

  # Configure swaylock
  programs.swaylock = {
    enable = true;
    settings = {
      color = "1e1e2e";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "313244";
      ring-color = "11111b";
      inside-color = "1e1e2e";
      key-hl-color = "89b4fa";
      separator-color = "00000000";
      text-color = "cdd6f4";
      text-caps-lock-color = "";
      line-caps-lock-color = "";
      inside-caps-lock-color = "";
      ring-caps-lock-color = "";
      inside-clear-color = "";
      text-clear-color = "";
      ring-clear-color = "";
      line-clear-color = "";
      inside-ver-color = "";
      text-ver-color = "";
      ring-ver-color = "";
      line-ver-color = "";
      inside-wrong-color = "";
      text-wrong-color = "";
      ring-wrong-color = "";
      line-wrong-color = "";
    };
  };

  # Configure alacritty terminal
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
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          dim_foreground = "#7f849c";
          bright_foreground = "#cdd6f4";
        };
        cursor = {
          text = "#1e1e2e";
          cursor = "#f5e0dc";
        };
        vi_mode_cursor = {
          text = "#1e1e2e";
          cursor = "#b4befe";
        };
        search = {
          matches = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
          focused_match = {
            foreground = "#1e1e2e";
            background = "#a6e3a1";
          };
        };
        footer_bar = {
          foreground = "#1e1e2e";
          background = "#a6adc8";
        };
        hints = {
          start = {
            foreground = "#1e1e2e";
            background = "#f9e2af";
          };
          end = {
            foreground = "#1e1e2e";
            background = "#a6adc8";
          };
        };
        selection = {
          text = "#1e1e2e";
          background = "#f5e0dc";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
        dim = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        indexed_colors = [
          { index = 16; color = "#fab387"; }
          { index = 17; color = "#f5e0dc"; }
        ];
      };
    };
  };

  # GTK configuration for consistent theming
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Configure environment variables
  home.sessionVariables = {
    # Required for niri
    NIXOS_OZONE_WL = "1";
    #MOZ_ENABLE_WAYLAND = "1";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # Additional packages that are useful with niri
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
  ];

  # Create niri config file with sensible defaults
  xdg.configFile."niri/config.kdl".text = ''
    // Niri configuration file
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
        gaps 16

        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 4
            active-color "#89b4fa"
            inactive-color "#45475a"
        }

        border {
            width 2
            active-color "#89b4fa"
            inactive-color "#45475a"
        }
    }

    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swaybg" "-i" "/run/current-system/sw/share/backgrounds/gnome/blobs-l.svg" "-m" "fill"

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
        // Example: make all niri config windows centered and floating
        matches app-id=r#"^org\.gnome\."#
        default-column-width { proportion 0.5; }
    }

    binds {
        // Mod key is Super when running in TTY, Alt when running nested
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Programs
        Mod+T { spawn "alacritty"; }
        Mod+D { spawn "fuzzel"; }
        Super+Alt+L { spawn "swaylock"; }

        // Window management
        Mod+Q { close-window; }

        // Focus movement
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

        // Workspace management
        Mod+U           { focus-workspace-down; }
        Mod+I           { focus-workspace-up; }
        Mod+PageDown    { focus-workspace-down; }
        Mod+PageUp      { focus-workspace-up; }

        // Move window to workspace
        Mod+Ctrl+U           { move-column-to-workspace-down; }
        Mod+Ctrl+I           { move-column-to-workspace-up; }
        Mod+Ctrl+PageDown    { move-column-to-workspace-down; }
        Mod+Ctrl+PageUp      { move-column-to-workspace-up; }

        // Move workspace
        Mod+Shift+U           { move-workspace-down; }
        Mod+Shift+I           { move-workspace-up; }
        Mod+Shift+PageDown    { move-workspace-down; }
        Mod+Shift+PageUp      { move-workspace-up; }

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
        Mod+Shift+V { toggle-floating-focus; }

        // Screenshots
        Print { screenshot-screen; }
        Alt+Print { screenshot-window; }
        Ctrl+Print { screenshot; }

        // Media keys
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        // Brightness control
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "10%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "10%-"; }

        // System
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        // Number keys for workspace switching
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
