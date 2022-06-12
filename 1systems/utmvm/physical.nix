{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./config.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "cifs" ];
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    interfaces.enp0s6.useDHCP = true;
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

    "/home/enno/repos" = {
      device = "\\\\\\\\192.168.64.1\\\\repos";
      fsType = "cifs";
      options = [ "uid=1000" "gid=100" "credentials=/root/smbcredentials" ];
    };
  };
}
