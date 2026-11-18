# images/iso.nix
{
  lib,
  pkgs,
  ...
}:
##   - Build iso:
# nix build .#iso
##   - Find installation device (eg. /dev/sdX):
# lsblk
##   - Write to thumb-drive:
# sudo dd bs=4M if=result/iso/my-nixos-live.iso of=/dev/sdX status=progress oflag=sync
{
  imports = [
    ./base-config.nix
    ../../hosts/common/core/yubikey.nix # pcscd + age-plugin-yubikey, for sops on a new machine
    ../../hosts/common/core/regular-programs.nix
    ../../hosts/common/optional/1password.nix
  ];

  isoImage.volumeID = lib.mkForce "my-nixos-live";
  # `isoImage.isoName` was renamed to `image.fileName` in NixOS 25.05.
  image.fileName = lib.mkForce "my-nixos-live.iso";
  # Use zstd instead of xz for compressing the liveUSB image, it's 6x faster and 15% bigger.
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # Setup 1Password to be able to log into an account if needed.
  modules._1password = {
    enable = true;
    polkitPolicyOwners = ["john"];
  };

  # Enable claude code for troubleshooting
  environment.systemPackages = with pkgs; [
    claude-code
    yubikey-manager # ykman, to check/unblock a YubiKey
    (callPackage ../../scripts/sops-tools.nix {}) # sops-new-host, sops-breakglass, ... (see docs/sops.md)
  ];

  ########################### SOPS ##########################
  # Plug in any registered YubiKey and `sops` just works (identity stubs aren't secret).
  # Rebuild the ISO if secrets/yubikey-identities.txt changes.
  environment.variables.SOPS_AGE_KEY_FILE = "${../../secrets/yubikey-identities.txt}";

  # pcscd only lets *active local* sessions use the card by default. Also allow wheel users,
  # so it works when you SSH into the live USB with the YubiKey plugged into it.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.debian.pcsc-lite.access_pcsc" ||
           action.id == "org.debian.pcsc-lite.access_card") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
