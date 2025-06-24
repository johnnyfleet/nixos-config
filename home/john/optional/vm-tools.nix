## Installs key tools that are useful for virtual machine management. 

{ pkgs, inputs, system, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    guestfs-tools # `virt-sparsify and other libvirt tools
    quickemu # Quickly create and run vms.
  ];

  # Configure virt-manager to correctly connect to the libvirt daemon.
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

}