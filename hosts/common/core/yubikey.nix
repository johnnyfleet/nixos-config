# Configures support for YubiKey in the system.
{
  config,
  pkgs,
  ...
}: {
  ########################### YUBIKEY #############################

  # Enable smartcard reader - for Yubikey reading.
  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
  };

  environment.systemPackages = with pkgs; [age-plugin-yubikey];
}
