{ ... }:
let
  disk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNF1K627058";
in
{
  imports =
    [
      ./config.nix
      ../../2configs/hw/tp-x280.nix
    ];

  system.stateVersion = "19.09";

  fileSystems."/" =
    {
      fsType = "tmpfs";
      options = [ "size=2000M" "mode=1755" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/mapper/home";
      fsType = "xfs";
      encrypted = {
        enable = true;
        blkDev = "/dev/p3vg/home";
        label = "home";
      };
      options = [ "nodev" "nosuid" ];
    };
  boot.initrd.luks.devices.home.preLVM = false;

  fileSystems."/nix" =
    {
      device = "/dev/p3vg/nix";
      fsType = "xfs";
      options = [ "nodev" "noatime" "nosuid" ];
    };

  fileSystems."/persist" =
    {
      device = "/dev/mapper/persist";
      fsType = "xfs";
      encrypted = {
        enable = true;
        blkDev = "/dev/p3vg/persist";
        label = "persist";
      };
      options = [ "nodev" "nosuid" "noexec" ];
    };
  boot.initrd.luks.devices.persist.preLVM = false;

  fileSystems."/sync" =
    {
      device = "/dev/mapper/sync";
      fsType = "xfs";
      encrypted = {
        enable = true;
        blkDev = "/dev/p3vg/sync";
        label = "sync";
      };
      options = [ "nodev" "nosuid" ];
    };
  boot.initrd.luks.devices.sync.preLVM = false;

  fileSystems."/var/log" =
    {
      device = "/dev/mapper/var-log";
      fsType = "xfs";
      encrypted = {
        enable = true;
        blkDev = "/dev/p3vg/var-log";
        label = "var-log";
      };
      options = [ "nodev" "nosuid" "noexec" ];
    };
  boot.initrd.luks.devices.var-log.preLVM = false;

  fileSystems."/var/src" =
    {
      device = "/dev/mapper/var-src";
      fsType = "xfs";
      encrypted = {
        enable = true;
        blkDev = "/dev/p3vg/var-src";
        label = "var-src";
      };
      neededForBoot = true; # mount early for passwd provisioning
      options = [ "nodev" "nosuid" "noexec" ];
    };
  boot.initrd.luks.devices.var-src.preLVM = false;

  fileSystems."/boot" =
    {
      device = "${disk}-part1";
      fsType = "vfat";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  swapDevices =
    [
      {
        device = "/dev/mapper/swap";
        encrypted = {
          enable = true;
          blkDev = "/dev/p3vg/swap";
          label = "swap";
        };
      }
    ];
  boot.initrd.luks.devices.swap.preLVM = false;

  networking.hostId = "d0ee5ec4"; # required for zfs
  boot.kernelParams = [ "systemd.machine_id=5d2b800f3d82434b8f7a656d2e130e06" ];
}
