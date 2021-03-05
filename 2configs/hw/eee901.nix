{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "sd_mod" ];

  nix.maxJobs = lib.mkDefault 2;

  # requires wifi firmware rt2860.bin
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];

  console.keyMap = "de-latin1";
}
