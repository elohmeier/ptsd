{ config, lib, pkgs, modulesPath }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/vda2";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/vda1";
      fsType = "vfat";
    };
  };
}
