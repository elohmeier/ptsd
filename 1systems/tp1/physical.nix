let
  disk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNF1K627058";
  vgPrefix = "/dev/disk/by-id/dm-name-p2vg";
in
{
  imports =
    [
      ./config.nix
      <ptsd/2configs/hw/tp-x280.nix>
    ];

  system.stateVersion = "19.09";

  boot.initrd.luks.devices.p2 = {
    device = "${disk}-part2";
  };

  fileSystems."/" =
    {
      device = "${vgPrefix}-root";
      fsType = "ext4";
    };

  fileSystems."/home" =
    {
      device = "${vgPrefix}-home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}-nix";
      fsType = "ext4";
    };

  fileSystems."/var" =
    {
      device = "${vgPrefix}-var";
      fsType = "ext4";
    };

  fileSystems."/var/log" =
    {
      device = "${vgPrefix}-var--log";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "${disk}-part1";
      fsType = "vfat";
    };

  swapDevices =
    [
      { device = "${vgPrefix}-swap"; }
    ];

  networking.hostId = "d0ee5ec4";
}
