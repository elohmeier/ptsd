{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/hetzner-vm.nix>
    #<ptsd/2configs/luks-ssh-unlock.nix>
  ];

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/sda2";
      preLVM = true;
    }
  ];

  fileSystems."/" = {
    device = "/dev/vg/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
    }
  ];
}
