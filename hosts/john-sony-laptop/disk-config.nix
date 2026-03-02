{lib, ...}: {
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        # Provide the real device at run time with:
        #   --disk disk1 /dev/nvme0n1
        # or set it here:
        # device = "/dev/disk/by-id/your-disk-id";
        device = lib.mkDefault "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "500M";
              type = "ef00"; # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            pv = {
              name = "pv";
              size = "100%";
              type = "8e00"; # Linux LVM
              content = {
                type = "lvm_pv";
                vg = "vg0";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vg0 = {
        type = "lvm_vg";
        lvs = {
          root = {
            name = "lv_root";
            size = "100GiB";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              # mountOptions = [ "noatime" ];
            };
          };

          home = {
            name = "lv_home";
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
              # mountOptions = [ "noatime" ];
            };
          };

          # Optional: add swap as an LV
          # swap = {
          #   name = "lv_swap";
          #   size = "16GiB";
          #   content = { type = "swap"; };
          # };
        };
      };
    };
  };
}
