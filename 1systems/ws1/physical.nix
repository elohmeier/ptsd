{ config, ... }:

let
  disk = "/dev/disk/by-id/nvme-Force_MP600_192482300001285612C9";
  vgPrefix = "/dev/disk/by-id/dm-name-p5vg";
in
{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/ws2019.nix>
  ];

  system.stateVersion = "19.09";

  boot.initrd.luks.devices = {
    p5 = {
      device = "${disk}-part5";
    };

    usbssd = {
      device = "/dev/disk/by-id/usb-Inateck_NS1066_0123456789ABCDE-0:0-part1";
      preLVM = false;
      keyFile = "${vgPrefix}-usbssdkey";
      keyFileSize = 4096;
      fallbackToPassword = true;
    };
  };

  fileSystems."/" =
    {
      device = "${vgPrefix}-root";
      fsType = "ext4";
    };

  fileSystems."/home" =
    {
      device = "${vgPrefix}-home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}-nix";
      fsType = "ext4";
    };

  fileSystems."/var" =
    {
      device = "${vgPrefix}-var";
      fsType = "ext4";
    };

  fileSystems."/var/lib/libvirt/images" =
    {
      device = "${vgPrefix}-var--lib--libvirt--images";
      fsType = "ext4";
    };

  fileSystems."/var/log" =
    {
      device = "${vgPrefix}-var--log";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "${disk}-part2";
      fsType = "vfat";
    };

  fileSystems."/mnt/win" =
    {
      device = "${disk}-part4";
      fsType = "ntfs-3g";
      options = [ "nofail" ];
    };

  swapDevices =
    [
      { device = "${vgPrefix}-swap"; }
    ];

  networking.hostId = "8c5598b5"; # required for zfs
}
