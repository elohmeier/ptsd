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

  # name "eth0" required for initrd ssh unlock
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="a8:a1:59:04:c6:f8", NAME="eth0"
  '';

  nix.maxJobs = lib.mkDefault 4;
  hardware.cpu.intel.updateMicrocode = true;

  i18n.consoleKeyMap = "de-latin1";
}
