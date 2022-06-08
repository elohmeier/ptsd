{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.useDHCP = true;

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

  users.users.root.hashedPassword = "";
}
