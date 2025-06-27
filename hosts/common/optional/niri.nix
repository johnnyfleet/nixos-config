{ pkgs, inputs, ... }:

{
  # Create niri session file for display manager
  services.displayManager.sessionPackages = [ inputs.niri.packages.${pkgs.system}.niri ];

  # Enable Plymouth at boot for smooth transitions
  boot.plymouth.enable = true;

  # Display manager configuration is handled by plasma-minimal
  # Commented out to avoid conflicts when both are enabled
  # services.displayManager = {
  #   sddm.enable = true;
  #   sddm.wayland.enable = true;
  #   defaultSession = "niri";
  # };

  # XDG portal configuration - extend what plasma-minimal provides
  xdg.portal = {
    # enable = true;  # Already enabled by plasma-minimal
    wlr.enable = true;  # Add wlr support for niri
    extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk  # Likely already provided by plasma
      # xdg-desktop-portal-gnome  # May conflict with plasma
    ];
  };

  # Enable polkit for system authentication dialogs
  # security.polkit.enable = true;  # Already enabled by plasma-minimal

  # Enable hardware support
  # hardware = {
  #   graphics.enable = true;  # Already handled by plasma-minimal
  #   bluetooth.enable = true;  # Already handled by plasma-minimal
  # };

  # Pipewire for audio - ALREADY CONFIGURED in core configuration.nix
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   jack.enable = true;
  # };

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

  # Font configuration - ALREADY CONFIGURED in core configuration.nix
  # Core already includes: dejavu-sans-mono, jetbrains-mono, space-mono
  # fonts = {
  #   enableDefaultPackages = true;
  #   packages = with pkgs; [
  #     nerd-fonts.fira-code
  #     nerd-fonts.jetbrains-mono  # Already in core
  #     font-awesome
  #   ];
  # };

  # System services for better desktop experience
  # Most services are already handled by plasma-minimal or core configuration
  services = {
    # Thumbnail generation
    tumbler.enable = true;
    
    # GVfs for trash and other file operations
    gvfs.enable = true;
    
    # UDISKS2 for automounting
    udisks2.enable = true;
    
    # D-Bus
    # dbus.enable = true;  # Already enabled by core
  };

  # Configure keymap - may conflict with plasma's X11 configuration
  # services.xserver = {
  #   xkb.layout = "us";
  #   xkb.variant = "";
  # };
}
