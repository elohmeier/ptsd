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
      gpu_mem=192
    '';

    # usb otg:
    # dtoverlay=dwc2

    # hdmi_enable_4kp60=1
  };
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelModules = [ "dwc2" ];

  boot.consoleLogLevel = 7;

  hardware.opengl = {
    setLdLibraryPath = true;
    package = pkgs.mesa_drivers;
  };
  hardware.deviceTree = {
    base = pkgs.device-tree_rpi;
    overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
  };
  services.xserver.videoDrivers = [ "modesetting" ];

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

  console.keyMap = "de-latin1";

  #   swapDevices = [
  #     {
  #       device = "/swapfile";
  #     }
  #   ];
}
