{ config, lib, pkgs, ... }:

{
  imports = [
    ./config.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
    firmwareConfig = ''
      gpu_mem=192
      dtoverlay=dwc2,dr_mode=host
      dtparam=sd_poll_once=on
      enable_uart=1
    '';

    # usb otg:
    # dtoverlay=dwc2

    # hdmi_enable_4kp60=1

    # not yet supported
    # uboot.enable = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  # boot.kernelModules = [ "dwc2" ];

  boot.consoleLogLevel = 7;

  #hardware.opengl = {
  #  enable = true;
  #  setLdLibraryPath = true;
  #  package = pkgs.mesa_drivers;
  #};
  # hardware.deviceTree = {
  #   kernelPackage = pkgs.linux_rpi4;
  #   overlays = [
  #     # {
  #     #   name = "usbc-host";
  #     #   # from https://github.com/raspberrypi/linux/blob/rpi-4.19.y/arch/arm/boot/dts/overlays/dwc2-overlay.dts
  #     #   # see also https://www.raspberrypi.org/forums/viewtopic.php?t=246348#p1622016
  #     #   # changed: dr_mode = "host"
  #     #   dtsText = ''
  #     #     /dts-v1/;
  #     #     /plugin/;

  #     # ../..
  #     #       compatible = "brcm,bcm2835";

  #     #       fragment@0 {
  #     #         target = <&usb>;
  #     #         #address-cells = <1>;
  #     #         #size-cells = <1>;
  #     #         dwc2_usb: __overlay__ {
  #     #           compatible = "brcm,bcm2835-usb";
  #     #           dr_mode = "host";
  #     #           g-np-tx-fifo-size = <32>;
  #     #           g-rx-fifo-size = <558>;
  #     #           g-tx-fifo-size = <512 512 512 512 512 256 256>;
  #     #           status = "okay";
  #     #         };
  #     #       };

  #     #       __overrides__ {
  #     #         dr_mode = <&dwc2_usb>, "dr_mode";
  #     #         g-np-tx-fifo-size = <&dwc2_usb>,"g-np-tx-fifo-size:0";
  #     #         g-rx-fifo-size = <&dwc2_usb>,"g-rx-fifo-size:0";
  #     #       };
  #     #     };
  #     #   '';
  #     # }
  #     { name = "vc4-fkms-v3d"; dtboFile = "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo"; }
  #   ];
  # };
  #services.xserver.videoDrivers = [ "modesetting" ];

  boot.supportedFilesystems = [ "vfat" ];

  #  fileSystems = {
  #    "/boot" = {
  #      # sdcard
  #      #device = "/dev/disk/by-label/NIXOS_BOOT";

  #      # usb drive
  #      device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S1AXNSADB07578D-part1";
  #      fsType = "vfat";
  #    };
  #    "/" = {
  #      # sdcard
  #      #device = "/dev/disk/by-label/NIXOS_SD";

  #      # usb drive
  #      device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S1AXNSADB07578D-part2";
  #      fsType = "ext4";
  #    };
  #  };

  console.keyMap = "de-latin1";

  #   swapDevices = [
  #     {
  #       device = "/swapfile";
  #     }
  #   ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "console=ttyAMA0,115200"
    "console=tty1"
  ];
}
