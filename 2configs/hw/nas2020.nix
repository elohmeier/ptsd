{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "ahci"
    "r8169" # ethernet driver
    "xhci_pci"
    "uas"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "hid_microsoft"
  ];

  boot.initrd.kernelModules = [ "dm-snapshot" ];

  boot.kernelModules = [ "kvm-intel" ];

  nix.maxJobs = lib.mkDefault 4;

  console.keyMap = "de-latin1";

  hardware = {
    cpu.intel.updateMicrocode = true;
    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];
  };
}
