{
  disk ? "/dev/vdb",
}:
{
  disk = {
    vdb = {
      type = "disk";
      device = disk;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "1MiB";
            end = "100MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              options = [
                "nofail"
                "nodev"
                "nosuid"
                "noexec"
              ];
            };
          }
          {
            type = "partition";
            name = "primary";
            start = "100MiB";
            end = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
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
          type = "lvm_lv";
          size = "5000M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            options = [
              "nodev"
              "noatime"
            ];
          };
        };
        home = {
          type = "lvm_lv";
          size = "1000M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
            options = [
              "nodev"
              "nosuid"
            ];
          };
        };
        var = {
          type = "lvm_lv";
          size = "1000M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/var";
            options = [
              "nodev"
              "nosuid"
              "noexec"
            ];
          };
        };
      };
    };
  };
}
