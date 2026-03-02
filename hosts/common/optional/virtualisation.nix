{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation;
in {
  options.modules.virtualisation = {
    enable = mkEnableOption "libvirt virtualization";

    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users to add to the libvirtd group";
      example = ["john"];
    };

    enableTPM = mkOption {
      type = types.bool;
      default = true;
      description = "Enable TPM emulation for VMs";
    };

    enableSpice = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SPICE guest tools for improved host-guest interaction";
    };

    enableUSBRedirection = mkOption {
      type = types.bool;
      default = true;
      description = "Enable USB device redirection to VMs";
    };

    trustedInterfaces = mkOption {
      type = types.listOf types.str;
      default = ["virbr0"];
      description = "Network interfaces to trust through firewall";
    };
  };

  config = mkIf cfg.enable {
    # Enable the libvirt daemon
    virtualisation.libvirtd.enable = true;
    users.groups.libvirtd.members = cfg.users;

    # Enable TPM emulation
    virtualisation.libvirtd.qemu = mkIf cfg.enableTPM {
      swtpm.enable = true;
    };

    # Enable the virt-manager GUI
    programs.virt-manager.enable = true;

    # VM guest additions to improve host-guest interaction
    services.spice-vdagentd.enable = cfg.enableSpice;
    services.qemuGuest.enable = cfg.enableSpice;
    services.spice-autorandr.enable = cfg.enableSpice;
    virtualisation.spiceUSBRedirection.enable = cfg.enableUSBRedirection;
    networking.firewall.trustedInterfaces = cfg.trustedInterfaces;

    # Install viewer and tools
    environment.systemPackages = with pkgs; [
      remmina
      swtpm # For TPM support in VMs
      virtiofsd # For virtio file system support - sharing folders to guest
      winboat # UI helper to install and manage Windows VMs + run office365 seamlessly
    ];
  };
}
