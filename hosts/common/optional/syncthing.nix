{ config, pkgs, ... }:
{
  # Enable Syncthing. Access through http://127.0.0.1:8384/ 
  # NOTE: Gui is not opened in firewall by default. If you do set the password below. 
  services.syncthing = {
    enable = true;
    openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
    # Optional: GUI credentials (can be set in the browser instead)
    /* settings.gui = {
      user = "myuser";
      password = "mypassword";
    }; */
  };
}
