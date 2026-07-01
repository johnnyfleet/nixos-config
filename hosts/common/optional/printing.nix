## Generic CUPS + Avahi printing setup.
## See https://wiki.nixos.org/wiki/Printing
##
## Printer-specific configuration (drivers, ensurePrinters entries) lives in the
## per-printer modules imported below. Add a new printer by creating a
## printing-<make>-<model>.nix file and importing it here.
{...}: {
  imports = [
    ./printing-epson-et-8550.nix # default printer
    ./printing-hp-photosmart-5520.nix
  ];

  # Enable CUPS to print documents.
  # Access CUPS UI via http://localhost:631/
  services.printing.enable = true;

  # Enable auto discovery of printers on the network.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Allow discovery using this port range. See: https://discourse.nixos.org/t/how-to-detect-what-firewall-ports-i-need-to-open-for-a-certain-service/37314/6
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 49152;
      to = 65535;
    }
  ];
}
