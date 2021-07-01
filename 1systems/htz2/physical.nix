{ config, pkgs, ... }:
let
  vgPrefix = "/dev/vg";
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
      device = "${vgPrefix}/root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/sda1";
      fsType = "ext4";
      options = [ "nofail" ];
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
        options = [ "nofail" ];
      };

    "/var/lib/private/maddy" = {
      device = "${vgPrefix}/var-lib-private-maddy";
      fsType = "ext4";
      options = [ "nofail" ];
    };

    "/var/log" =
      {
        device = "${vgPrefix}/var-log";
        fsType = "ext4";
        options = [ "nofail" ];
      };

    "/var/src" =
      {
        device = "${vgPrefix}/var-src";
        fsType = "ext4";
        neededForBoot = true; # mount early for passwd provisioning
      };
  };

  swapDevices = [
    { device = "${vgPrefix}/swap"; }
  ];
}
