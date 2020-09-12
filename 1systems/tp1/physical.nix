{ lib, pkgs, ... }:
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
      #device = "${vgPrefix}-root";
      #fsType = "ext4";
      fsType = "tmpfs";
      options = [ "size=500M" "mode=1755" ];
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

  fileSystems."/persist" =
    {
      device = "${vgPrefix}-persist";
      fsType = "ext4";
    };

  fileSystems."/var/src" =
    {
      device = "${vgPrefix}-var--src";
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

  networking.hostId = "d0ee5ec4"; # required for zfs
  boot.kernelParams = [ "systemd.machine_id=5d2b800f3d82434b8f7a656d2e130e06" ];

  #boot.initrd.postDeviceCommands = lib.mkAfter ''
  #  ${pkgs.e2fsprogs}/bin/mkfs.ext4 ${vgPrefix}-root
  #'';
}
