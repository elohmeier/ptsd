{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/eee901.nix>
  ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  fileSystems."/var/src" = {
    device = "/dev/sdb2";
    fsType = "ext4";
  };

  # zfs will automatically mount the subvolumes
  fileSystems."/mnt/backup" =
    {
      device = "nw26"; # change the device name here when switching USB drives
      fsType = "zfs";
      options = [
        "nofail"
        "x-systemd.device-timeout=3s"
      ];
    };

  swapDevices = [ { device = "/dev/sdb1"; } ];

  networking.hostId = "614E1851"; # required for zfs

  # fix failing rngd.service because of lack of entropy sources
  security.rngd.enable = false;
  services.haveged.enable = true;
}
