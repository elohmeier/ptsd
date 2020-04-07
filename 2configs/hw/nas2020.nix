{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

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

  #boot.kernelParams = [
  #"mitigations=off" # make linux fast again
  #];

  nix.maxJobs = lib.mkDefault 4;
  hardware.cpu.intel.updateMicrocode = true;

  console.keyMap = "de-latin1";
}
