{ config, pkgs, ... }:

let
  vgPrefix = "/dev/disk/by-id/dm-name-vg";
in
{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/hetzner-vm.nix>
    <ptsd/2configs/luks-ssh-unlock.nix>
  ];

  boot.initrd.luks.devices = [
    {
      name = "sda2_crypt";
      device = "/dev/sda2";
      preLVM = true;
    }
  ];

  fileSystems."/" = {
    device = "${vgPrefix}-root";
    fsType = "ext4";
  };

  fileSystems."/nix" = {
    device = "${vgPrefix}-nix";
    fsType = "ext4";
  };

  fileSystems."/var" = {
    device = "${vgPrefix}-var";
    fsType = "ext4";
  };

  fileSystems."/var/log" = {
    device = "${vgPrefix}-var--log";
    fsType = "ext4";
  };

  fileSystems."/var/src" = {
    device = "${vgPrefix}-var--src";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #   }
  # ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="96:00:00:4a:55:70", NAME="eth0"
  '';
}
