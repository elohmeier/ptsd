{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/hetzner-vm.nix>
    #<ptsd/2configs/luks-ssh-unlock.nix>
  ];

  # not working as of 2019-10-14
  # boot.kernelParams = [ "ip=159.69.186.234::172.31.1.1:255.255.255.255:htz1:eth0:off" ];

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
