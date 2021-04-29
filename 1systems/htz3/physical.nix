{ config, pkgs, ... }:
let
  vgPrefix = "/dev/disk/by-id/dm-name-vg";
in
{
  imports = [
    ./config.nix
    ../../2configs/hw/hetzner-vm.nix
    ../../2configs/luks-ssh-unlock.nix
  ];

  boot.initrd.luks.devices.root =
    {
      device = "/dev/sda2";
      preLVM = true;
    };

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

  fileSystems."/var/lib/fraam-gitlab" = {
    device = "${vgPrefix}-var--lib--fraam--gitlab";
    fsType = "ext4";
  };

  fileSystems."/var/lib/fraam-gitlab/gitlab/state/repositories" = {
    device = "${vgPrefix}-var--lib--fraam--gitlab--repos";
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

  zramSwap = {
    enable = true;
    numDevices = 1;
    swapDevices = 1;
    memoryPercent = 75;
    priority = 2; # should be higher than for disk-based swap devices to fallback to disk swap when zram is full
    algorithm = "zstd";
  };

  swapDevices = [
    {
      device = "${vgPrefix}-swap";
      priority = 1;
    }
  ];

  nix.maxJobs = 3;
}
