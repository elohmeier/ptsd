{ config, pkgs, ... }:
let
  disk = "/dev/disk/by-id/ata-Samsung_SSD_840_EVO_120GB_mSATA_S1KTNEADC05687F";
  vgPrefix = "/dev/sysvg";
in
{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/nuc.nix>
  ];

  system.stateVersion = "20.09";

  boot = {

    initrd.luks.devices.p2 = {
      device = "${disk}-part2";
    };
    kernelParams = [ "systemd.machine_id=5f0d47f06a0a486b82690748870e24b6" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "nw28" ];
  };

  fileSystems."/" =
    {
      fsType = "tmpfs";
      options = [ "size=1000M" "mode=1755" ];
    };

  fileSystems."/home" =
    {
      device = "${vgPrefix}/home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}/nix";
      fsType = "ext4";
    };

  fileSystems."/persist" =
    {
      device = "${vgPrefix}/persist";
      fsType = "ext4";
    };

  fileSystems."/var/src" =
    {
      device = "${vgPrefix}/var-src";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "${disk}-part1";
      fsType = "vfat";
    };

  swapDevices =
    [
      { device = "${vgPrefix}/swap"; }
    ];

  networking.hostId = "A621BDF3"; # needed for zfs
}
