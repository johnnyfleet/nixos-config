# Oracle Cloud Ampere A1 (aarch64 KVM, UEFI, paravirtualized boot volume).
# Best-effort until verified: regenerate during install with
#   nixos-anywhere --generate-hardware-config nixos-generate-config ./hosts/minecraft-server/hardware-configuration.nix ...
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "sd_mod"
    "nvme"
    "xhci_pci"
    "usbhid"
  ];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # OCI serial console (Ubuntu runs a getty on ttyAMA0).
  boot.kernelParams = ["console=ttyAMA0,115200" "console=tty1"];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
