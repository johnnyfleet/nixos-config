## Installs key tools that are useful for virtual machine management. 

{ pkgs, inputs, system, ... }:
{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    guestfs-tools # `virt-sparsify and other libvirt tools
    # Build quickemu from git master to fix QEMU 10.0.0 compatibility issue
    # See: https://github.com/quickemu-project/quickemu/pull/1640
    (quickemu.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "quickemu-project";
        repo = "quickemu";
        rev = "9f90d46ea195d62a8b84c6dd45ea5b1443bb3e46";
        sha256 = "sha256-M5/EIzh19VlxQ5yTEvupCa5j/PvyqBx7/WqXJ9319oo=";
      };
    }))
  ];

  # Configure virt-manager to correctly connect to the libvirt daemon.
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

}