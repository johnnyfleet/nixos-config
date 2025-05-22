## Setup CUPS and HPLIP for printing
## See https://wiki.nixos.org/wiki/Printing 
## Set up by manual discovery.
## Once completed set:
## Printing Quality = Best
## Page size = A4
## Two sided printing = Long edge

{ pkgs, ... }:

{
  # Enable CUPS to print documents.
  # Access CUPS UI via http://localhost:631/
  services.printing = {
    # run on first setup: sudo hp-setup -i -a
    enable  =  true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  environment.systemPackages = with pkgs; [
     hplipWithPlugin # HP Printer utility
  ];

  # Enable auto discovery of printers on the network.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Allow discovery using this port range. See: https://discourse.nixos.org/t/how-to-detect-what-firewall-ports-i-need-to-open-for-a-certain-service/37314/6
  networking.firewall.allowedUDPPortRanges = [
    { from = 49152; to = 65535; }
  ];

  # Add HP PhotosSmart 5520 printer. You shouldn't need to then setup through HPLIP. 
  # It also seems faster this way to print vs. HPLIP.
  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP_PhotoSmart_5520-NixOS";
        location = "Home";
        deviceUri = "hp:/net/Photosmart_5520_series?ip=192.168.1.110";
        model = "drv:///hp/hpcups.drv/hp-photosmart_5520_series.ppd";
        ppdOptions = {
          PageSize = "A4";
          OutputMode = "Best";
          OptionDuplex = "True";
          Duplex = "DuplexNoTumble";
        };
      }
    ];
    ensureDefaultPrinter = "HP_PhotoSmart_5520-NixOS";
  };
} 