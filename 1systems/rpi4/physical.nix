{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # required for wifi
  ];


  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
    firmwareConfig = ''
      dtoverlay=dwc2
    '';
  };
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelModules = [ "dwc2" ];

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
