{
  config,
  pkgs,
  ...
}: {
  # Enable Syncthing. Access through http://127.0.0.1:8384/
  # NOTE: Gui is not opened in firewall by default. If you do set the password below.
  services.syncthing = {
    enable = true;
    user = "john";
    openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
    dataDir = "/home/john/Pictures/Syncthing"; # Change this to your desired data directory
    configDir = "/home/john/.config/syncthing";
    # Optional: GUI credentials (can be set in the browser instead)
    /*
       settings.gui = {
      user = "myuser";
      password = "mypassword";
    };
    */
  };
}
