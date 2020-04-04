{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/nuc.nix>
  ];

  fileSystems."/" =
    {
      device = "nw10/root";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    {
      device = "nw10/tmp";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "nw10/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/0CB4-6539";
      fsType = "vfat";
    };

  # fileSystems."/mnt/int" =
  #   {
  #     device = "/dev/mapper/int_crypt";
  #     fsType = "ext4";
  #     encrypted = {
  #       enable = true;
  #       blkDev = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S1AXNSADB07578D-part1";
  #       keyFile = "/mnt-root/var/src/secrets/int-crypt-key";
  #       label = "int_crypt";
  #     };
  #   };

  # zfs will automatically mount the subvolumes
  # fileSystems."/mnt/backup" =
  #   {
  #     device = "nw27"; # change the device name here when switching USB drives
  #     fsType = "zfs";
  #     options = [
  #       "nofail"
  #       "x-systemd.device-timeout=3s"
  #     ];
  #   };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/81d2bce5-8319-4110-a718-ea506b27b536"; }
    ];

  networking.hostId = "A621BDF3"; # needed for zfs

}
