{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.opengl = {
    enable = true;
  };
  console.keyMap = "de-latin1";
}
