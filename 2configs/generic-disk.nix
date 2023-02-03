{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./nix-persistent.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # to format:
  # sgdisk -og -a1 -n1:2048:+1G -t1:EF00 -c1:boot -n2:0:0 -t2:8300 -c2:nix /dev/vda && mkfs.vfat -F32 -I -n boot /dev/vda1 && mkfs.ext4 -L nix -F /dev/vda2
  #
  # to prepare for nixos-install:
  # mkdir -p /mnt/boot /mnt/nix && mount /dev/vda1 /mnt/boot && mount /dev/vda2 /mnt/nix
  fileSystems = {

    "/" = {
      fsType = "tmpfs";
      options = [ "size=1G" "mode=1755" ];
    };


    "/boot" = {
      device = mkDefault "/dev/disk/by-partlabel/boot";
      fsType = mkDefault "vfat";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

    "/nix" = {
      device = mkDefault "/dev/disk/by-partlabel/nix";
      fsType = mkDefault "ext4";
      neededForBoot = true;
      options = [ "nodev" "noatime" ];
    };

  };
}
