{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules =
    [ "ahci" "ohci_pci" "ehci_pci" "usb_storage" "sd_mod" ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
    extraConfig =
      ''
        serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
        terminal_input --append serial
        terminal_output --append serial
      '';
  };

  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
  boot.extraModulePackages = [ ];

  nix.maxJobs = lib.mkDefault 2;

  console.keyMap = "de-latin1";
}
