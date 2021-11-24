{ lib, pkgs, ... }:
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
  ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ amdvlk ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };
  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
  console.keyMap = "de-latin1";
}
