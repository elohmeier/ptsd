{ lib, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # to format:
  # sgdisk -og -a1 -n1:2048:+1G -t1:EF00 -n2:0:0 -t2:8300 /dev/vda
  fileSystems = {
    "/" = {
      device = lib.mkDefault "/dev/vda2";
      fsType = "xfs";
    };

    "/boot" = {
      device = lib.mkDefault "/dev/vda1";
      fsType = "vfat";
    };
  };
}
