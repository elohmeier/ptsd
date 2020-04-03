{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "ahci" "ohci_pci" "ehci_pci" "usb_storage" "sd_mod" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
  boot.extraModulePackages = [];

  nix.maxJobs = lib.mkDefault 2;

  console.keyMap = "de-latin1";
}
