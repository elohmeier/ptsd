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

  networking.hostId = "d0ee5ec4";

  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/libvirt/qemu - - - - /persist/var/lib/libvirt/qemu"
  ];

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    ${pkgs.e2fsprogs}/bin/mkfs.ext4 ${vgPrefix}-root
  '';
}
