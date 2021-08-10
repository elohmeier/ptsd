{ ... }:
let
  disk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HAJQ-000L7_S3TNNF1K627058";
  vgPrefix = "/dev/sysVG";
in
{
  imports =
    [
      ./config.nix
      ../../2configs/hw/tp-x280.nix
    ];

  system.stateVersion = "19.09";

  boot.initrd.luks.devices.p2 = {
    device = "${disk}-part2";
  };

  fileSystems."/" =
    {
      fsType = "tmpfs";
      options = [ "size=2000M" "mode=1755" ];
    };

  fileSystems."/home" =
    {
      device = "${vgPrefix}/home";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}/nix";
      fsType = "ext4";
      options = [ "nodev" ];
    };

  fileSystems."/persist" =
    {
      device = "${vgPrefix}/persist";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/var/log" =
    {
      device = "${vgPrefix}/var-log";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/var/src" =
    {
      device = "${vgPrefix}/var-src";
      fsType = "ext4";
      neededForBoot = true; # mount early for passwd provisioning
      options = [ "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/boot" =
    {
      device = "${disk}-part1";
      fsType = "vfat";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  swapDevices =
    [
      { device = "${vgPrefix}/swap"; }
    ];

  networking.hostId = "d0ee5ec4"; # required for zfs
  boot.kernelParams = [ "systemd.machine_id=5d2b800f3d82434b8f7a656d2e130e06" ];
}
