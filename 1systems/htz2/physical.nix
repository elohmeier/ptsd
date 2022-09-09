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
        neededForBoot = true; # mount early for passwd provisioning
      };

    "/var/lib/maddy" = {
      device = "${vgPrefix}/maddy";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  swapDevices = [
    { device = "${vgPrefix}/swap"; }
  ];
}
