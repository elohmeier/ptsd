{ disks ? [ "/dev/nvme0n1" ], ... }: {
  disk = {
    nvme = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "1MiB";
            end = "512MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
              ];
            };
          }
          {
            name = "luks";
            start = "512MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          }
        ];
      };
    };
  };
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        nix = {
          size = "5000M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            # options = [ "nodev" "noatime" ];
          };
        };
        home = {
          size = "1000M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
            # options = [ "nodev" "nosuid" ];
          };
        };
        var = {
          size = "1000M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var";
            # options = [ "nodev" "nosuid" "noexec" ];
          };
        };
      };
    };
  };
}

