{ pkgs, ... }:

{

  # Enable Plymouth at boot
  boot.plymouth.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    defaultSession = "plasma";
  };

  services.desktopManager.plasma6.enable = true;

  # Enable polkit which should allow kate to run.
  security.polkit.enable = true;

  hardware = {
    bluetooth.enable = true;
  };


  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    #layout = "us";
    #xkbvariant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

}