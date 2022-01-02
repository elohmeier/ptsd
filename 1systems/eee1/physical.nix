{
  imports = [
    ./config.nix
    ../../2configs/hw/eee901.nix
  ];

  system.stateVersion = "21.05";

  boot.kernelParams = [
    "zfs.zfs_arc_max=536870912" # max ARC size: 512MB (instead of default 8GB)
    "mitigations=off" # make linux fast again
    "systemd.machine_id=cf37b16b84e8476db3c903a8ed4eb85a"
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "size=200M" "mode=1755" ];
  };

  fileSystems."/boot" =
    {
      device = "/dev/sysVG/boot";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/sysVG/nix";
      fsType = "ext4";
      neededForBoot = true;
      options = [ "nodev" "noatime" ];
    };

  fileSystems."/var/log" = {
    device = "/dev/sysVG/var-log";
    fsType = "ext4";
    options = [ "nofail" "nodev" "nosuid" "noexec" ];
  };

  fileSystems."/var/src" = {
    device = "/dev/sysVG/var-src";
    fsType = "ext4";
    neededForBoot = true; # mount early for passwd provisioning
    options = [ "nodev" "nosuid" "noexec" ];
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
    { device = "/dev/sysVG/swap"; priority = 1; }
  ];

  services.haveged.enable = true;
}
