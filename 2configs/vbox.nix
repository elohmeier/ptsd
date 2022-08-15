{ config, lib, pkgs, ... }:

{
  imports = [
    ./devenv.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "nvme" "ahci" "ohci_pci" "ehci_pci" "sr_mod" ];
    };
  };

  fileSystems."/" =
    {
      device = "/dev/nvme0n1p2";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };

  systemd.network.networks."40-enp" = {
    matchConfig.Driver = "virtio_net";
    networkConfig = {
      DHCP = "yes";
      IPv6PrivacyExtensions = "kernel";
    };
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  virtualisation.virtualbox.guest.enable = true;
}
