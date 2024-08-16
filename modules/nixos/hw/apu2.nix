# PC-Engines APU2c4

{ lib, ... }:

{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "ehci_pci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
  };

  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200n8"
  ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = lib.mkDefault 4;

  console.keyMap = "de-latin1";
}
