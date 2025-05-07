## Installs key tools that are useful for virtual machine management. 

{ pkgs, inputs, system, ... }:
{

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    guestfs-tools # `virt-sparsify and other libvirt tools
    quickemu # Quickly create and run vms.
  ];

}