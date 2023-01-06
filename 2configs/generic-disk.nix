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
