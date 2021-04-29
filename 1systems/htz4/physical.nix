{ config, pkgs, ... }:
let
  vgPrefix = "/dev/vg";
in
{
  imports = [
    ./config.nix
    ../../2configs/hw/hetzner-vm.nix
  ];

  fileSystems = {
    "/" = {
      device = "${vgPrefix}/root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    "/nix" =
      {
        device = "${vgPrefix}/nix";
        fsType = "ext4";
      };

    "/var" =
      {
        device = "${vgPrefix}/var";
        fsType = "ext4";
      };

    "/var/log" =
      {
        device = "${vgPrefix}/var-log";
        fsType = "ext4";
      };

    "/var/src" =
      {
        device = "${vgPrefix}/var-src";
        fsType = "ext4";
      };
  };
}
