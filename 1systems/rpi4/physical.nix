{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
  ];


  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  boot.consoleLogLevel = 7;

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  environment.noXlibs = true;
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  console.keyMap = "de-latin1";

  #   swapDevices = [
  #     {
  #       device = "/swapfile";
  #     }
  #   ];
}
