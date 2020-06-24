let
  disk = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_120GB_S21UNXAGB12736P";
  vgPrefix = "/dev/disk/by-id/dm-name-sysVG";
in
{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/nas2020.nix>
    <ptsd/2configs/luks-ssh-unlock.nix>
  ];

  system.stateVersion = "19.09";

  boot = {
    initrd.luks.devices.sysVG = {
      device = "${disk}-part2";
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        memtest86.enable = true;
      };
    };

    tmpOnTmpfs = true;
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "tank" ];
  };

  fileSystems = {
    "/" =
      {
        device = "${vgPrefix}-root";
        fsType = "ext4";
      };

    "/boot" =
      {
        device = "${disk}-part1";
        fsType = "vfat";
      };

    "/home" =
      {
        device = "${vgPrefix}-home";
        fsType = "ext4";
      };

    "/nix" =
      {
        device = "${vgPrefix}-nix";
        fsType = "ext4";
      };

    "/var" =
      {
        device = "${vgPrefix}-var";
        fsType = "ext4";
      };

    "/var/db/influxdb" =
      {
        device = "${vgPrefix}-var--db--influxdb";
        fsType = "ext4";
      };

    "/var/lib/prometheus2" =
      {
        device = "${vgPrefix}-var--lib--prometheus2";
        fsType = "ext4";
      };

    "/var/log" =
      {
        device = "${vgPrefix}-var--log";
        fsType = "ext4";
      };
  };

  swapDevices =
    [
      { device = "${vgPrefix}-swap"; }
    ];

  powerManagement.cpuFreqGovernor = "powersave";
  networking.hostId = "1591AF90"; # required for zfs
}
