{
  imports =
    [
      ./config.nix
      <ptsd/2configs/hw/tp-x280.nix>
    ];

  system.stateVersion = "19.09";

  boot.initrd.luks.devices.p2 = {
    device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNF1K627058-part2";
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-id/dm-name-p2vg-root";
      fsType = "ext4";
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-id/dm-name-p2vg-home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-id/dm-name-p2vg-nix";
      fsType = "ext4";
    };

  fileSystems."/var" =
    {
      device = "/dev/disk/by-id/dm-name-p2vg-var";
      fsType = "ext4";
    };

  fileSystems."/var/log" =
    {
      device = "/dev/disk/by-id/dm-name-p2vg-var--log";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNF1K627058-part1";
      fsType = "vfat";
    };

  swapDevices =
    [
      { device = "/dev/disk/by-id/dm-name-p2vg-swap"; }
    ];

  networking.hostId = "d0ee5ec4";
}
