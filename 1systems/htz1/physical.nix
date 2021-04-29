{ config, pkgs, ... }:
let
  vgPrefix = "/dev/disk/by-id/dm-name-vg";
in
{
  imports = [
    ./config.nix
    ../../2configs/hw/hetzner-vm.nix
    ../../2configs/luks-ssh-unlock.nix
  ];

  boot.initrd.luks.devices.root =
    {
      device = "/dev/sda2";
      preLVM = true;
    };

  fileSystems = {
    "/" = {
      device = "${vgPrefix}-root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    "/home" =
      {
        device = "${vgPrefix}-home";
        fsType = "ext4";
      };

    "/nix" =
      {
        device = "${vgPrefix}-nix";
        fsType = "ext4";
      };

    "/var" =
      {
        device = "${vgPrefix}-var";
        fsType = "ext4";
      };

    "/var/log" =
      {
        device = "${vgPrefix}-var--log";
        fsType = "ext4";
      };

    "/var/src" =
      {
        device = "${vgPrefix}-var--src";
        fsType = "ext4";
      };
  };

  swapDevices = [
    { device = "${vgPrefix}-swap"; }
  ];
}
