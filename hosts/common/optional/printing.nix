{ pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing = {
    # run on first setup: sudo hp-setup -i -a
    enable  =  true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  environment.systemPackages = with pkgs; [
     hplipWithPlugin # HP Printer utility
  ];

  # Allow discovery using this port range. See: https://discourse.nixos.org/t/how-to-detect-what-firewall-ports-i-need-to-open-for-a-certain-service/37314/6
  networking.firewall.allowedUDPPortRanges = [
    { from = 49152; to = 65535; }
  ];
}