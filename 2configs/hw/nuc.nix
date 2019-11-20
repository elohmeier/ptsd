{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # don't remove!!!
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "e1000e" ];
  boot.kernelModules = [ "kvm-intel" ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;
  boot.zfs.requestEncryptionCredentials = true;

  hardware.cpu.intel.updateMicrocode = true;

  i18n.consoleKeyMap = "de-latin1";
}
