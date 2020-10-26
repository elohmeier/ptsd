{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # don't remove!!!
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" ];
  nix.maxJobs = lib.mkDefault 4;
  hardware.cpu.intel.updateMicrocode = true;
  console.keyMap = "de-latin1";
}
