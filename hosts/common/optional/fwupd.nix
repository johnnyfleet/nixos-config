## Installs fwupd and fwupdmgr to manage firmware updates.

{ pkgs, ... }:
{ 
  services.fwupd.enable = true;      # starts the fwupd system daemon

  #Thunderbolt management
  environment.systemPackages = with pkgs; [
        bolt
  ];

  # Auto-start the bolt daemon
  systemd.user.services.bolt = {
    description = "Thunderbolt device management daemon";
    serviceConfig = {
      ExecStart = "${pkgs.bolt}/bin/boltd";
    };
    wantedBy = [ "default.target" ];
  };
}