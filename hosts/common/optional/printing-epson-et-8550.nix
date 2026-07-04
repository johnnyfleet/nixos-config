## Epson EcoTank ET-8550 printer (default printer).
## Generic CUPS/Avahi setup lives in ./printing.nix (which imports this file).
## See https://wiki.nixos.org/wiki/Printing
##
## Uses the Epson ESC/P-R v2 driver (epson-inkjet-printer-escpr2).
##
## !!! TODO: set the printer's network IP below (deviceUri) !!!
## Give it a static/DHCP-reserved address so it doesn't change. To find it:
##   - Printer panel: Settings > Network Settings > Print Status Sheet, or
##   - avahi-browse -rt _ipp._tcp   (once this module is active)
## To confirm the exact driver model string CUPS registered:
##   lpinfo -m | grep -i ET-8550
{pkgs, ...}: {
  # Epson ESC/P-R v2 driver.
  services.printing.drivers = [pkgs.epson-escpr2];

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Epson_ET-8550-NixOS";
        location = "Home";
        # TODO: replace 192.168.1.XXX with the ET-8550's IP address.
        deviceUri = "lpd://192.168.1.111/PASSTHRU";
        model = "epson-inkjet-printer-escpr2/Epson-ET-8550_Series-epson-escpr2-en.ppd";
        ppdOptions = {
          PageSize = "A4";
          MediaType = "PLAIN_HIGH"; # Plain paper - Best Quality
          Duplex = "DuplexNoTumble"; # 2-sided, long edge
        };
      }
    ];
    ensureDefaultPrinter = "Epson_ET-8550-NixOS";
  };
}
