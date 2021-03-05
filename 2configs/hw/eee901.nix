{ config, lib, pkgs, ... }:

{
  boot.initrd = {
    availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "sd_mod" ];
    kernelModules = [ "i915" ];
  };

  nix.maxJobs = lib.mkDefault 2;

  hardware.cpu.intel.updateMicrocode = true;

  # requires wifi firmware rt2860.bin
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  console.keyMap = "de-latin1";
}
