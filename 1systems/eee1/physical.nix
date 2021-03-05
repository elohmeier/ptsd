{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/eee901.nix>
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
    };

  fileSystems."/nix" =
    {
      device = "/dev/sysVG/nix";
      fsType = "ext4";
    };

  fileSystems."/var/src" = {
    device = "/dev/sysVG/var-src";
    fsType = "ext4";
  };

  zramSwap = {
    enable = true;
    numDevices = 1;
    swapDevices = 1;
    memoryPercent = 50;
    priority = 5;
    algorithm = "zstd";
  };

  services.haveged.enable = true;
}
