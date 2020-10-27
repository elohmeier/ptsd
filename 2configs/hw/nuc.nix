{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # don't remove!!!
    ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "e1000e" ];
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "mitigations=off" # make linux fast again
    ];
  };
  nix.maxJobs = lib.mkDefault 4;
  hardware.cpu.intel.updateMicrocode = true;
  console.keyMap = "de-latin1";
}
