{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/hetzner-vm.nix>
    <ptsd/2configs/luks-ssh-unlock.nix>
  ];

  boot.initrd.luks.devices.root =
    {
      device = "/dev/sda2";
      preLVM = true;
    };

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

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="96:00:00:13:17:74", NAME="eth0"
  '';
}
