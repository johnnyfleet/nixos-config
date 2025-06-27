{ pkgs, inputs, ... }:

{
  # Create niri session file for display manager
  services.displayManager.sessionPackages = [ inputs.niri.packages.${pkgs.system}.niri ];

  # Enable Plymouth at boot for smooth transitions
  boot.plymouth.enable = true;

  # Enable display manager
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    defaultSession = "niri";
  };

  # Enable XDG portal for screen sharing and desktop integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # Enable polkit for system authentication dialogs
  security.polkit.enable = true;

  # Enable hardware support
  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  # Pipewire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Essential packages for niri functionality
  environment.systemPackages = with pkgs; [
    # Application launcher
    fuzzel
    
    # Terminal
    alacritty
    
    # Status bar
    waybar
    
    # Screen locker
    swaylock
    
    # Wallpaper setter
    swaybg
    
    # Notification daemon
    mako
    
    # Screenshot tools
    grim
    slurp
    
    # File manager
    nautilus
    
    # Network manager applet
    networkmanagerapplet
    
    # Audio control
    pavucontrol
    
    # Brightness control
    brightnessctl
    
    # XWayland satellite for X11 app compatibility
    xwayland-satellite
    
    # Clipboard manager
    wl-clipboard
    
    # Display configuration
    wlr-randr
    
    # GTK themes and icons
    adwaita-icon-theme
    gnome-themes-extra

    # Niri package
    inputs.niri.packages.${pkgs.system}.niri
  ];

  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      font-awesome
    ];
  };

  # System services for better desktop experience
  services = {
    # Thumbnail generation
    tumbler.enable = true;
    
    # GVfs for trash and other file operations
    gvfs.enable = true;
    
    # UDISKS2 for automounting
    udisks2.enable = true;
    
    # D-Bus
    dbus.enable = true;
    
    # Network Manager
    networkmanager.enable = true;
  };

  # Configure keymap
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable experimental features needed for niri
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
