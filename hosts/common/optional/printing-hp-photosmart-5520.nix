## HP PhotoSmart 5520 printer.
## Generic CUPS/Avahi setup lives in ./printing.nix (which imports this file).
## See https://wiki.nixos.org/wiki/Printing
##
## Set up by manual discovery. Once added, in the print dialog set:
##   Printing Quality  = Best
##   Page size         = A4
##   Two sided printing = Long edge
##
## First-time HPLIP setup (usually not needed thanks to ensurePrinters below,
## and printing this way tends to be faster than via HPLIP):
##   sudo hp-setup -i -a
{pkgs, ...}: {
  # HPLIP driver + utility for the HP printer.
  services.printing.drivers = [pkgs.hplipWithPlugin];

  environment.systemPackages = with pkgs; [
    hplipWithPlugin # HP Printer utility
  ];

  # Add HP PhotoSmart 5520 printer. You shouldn't need to set up through HPLIP.
  # It also seems faster this way to print vs. HPLIP.
  hardware.printers.ensurePrinters = [
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
}
