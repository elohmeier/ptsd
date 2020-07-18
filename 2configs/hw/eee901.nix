{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.availableKernelModules =
    [ "uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=536870912" # max ARC size: 512MB (instead of default 8GB)
    "mitigations=off" # make linux fast again
  ];

  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];

  nix.maxJobs = lib.mkDefault 2;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  services.haveged.enable = true;
}
