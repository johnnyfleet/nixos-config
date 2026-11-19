# john-laptop's software on a QEMU VM. Used to rehearse a new-machine install end to end:
# nixos-anywhere + sops-new-host (pre-generated host key, first boot decrypts secrets).
# Walkthrough: docs/sops.md -> "Rehearsing an install in a VM".
#
# Shares hosts/john-laptop/default.nix (via johnLaptopModules in flake.nix); only the
# hardware, disk layout, bootloader paths and identity differ.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  # Own identity: separate sops recipient in secrets/keys.nix, can read common.yaml and
  # (if it ever exists) secrets/john-laptop-test.yaml - NOT secrets/john-laptop.yaml.
  networking.hostName = lib.mkForce "john-laptop-test";

  # Kindo S3 secrets are in secrets/john-laptop.yaml; disabling the module also drops
  # its sops secrets/template (see hosts/john-laptop/default.nix).
  home-manager.users.john.kindo.s3.enable = lib.mkForce false;

  # john-laptop splits ESP (/efi) and XBOOTLDR (/boot); the VM uses one ESP at /boot.
  boot.loader.efi.efiSysMountPoint = lib.mkForce "/boot";
  boot.loader.systemd-boot.xbootldrMountPoint = lib.mkForce null;

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_blk" "virtio_scsi" "sr_mod"];
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.openssh.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
