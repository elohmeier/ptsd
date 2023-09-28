let
  disk = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_120GB_S21UNXAGB12736P";
  vgPrefix = "/dev/disk/by-id/dm-name-sysVG";
in
{
  imports = [
    ./config.nix
    ../../2configs/hw/nas2020.nix
    ../../2configs/luks-ssh-unlock.nix
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
        options = [ "nodev" "nosuid" "noexec" ];
      };

    "/home" =
      {
        device = "${vgPrefix}-home";
        fsType = "ext4";
        options = [ "nodev" "nosuid" "noexec" ];
      };

    "/nix" =
      {
        device = "${vgPrefix}-nix";
        fsType = "ext4";
        options = [ "nodev" ];
      };

    "/var" =
      {
        device = "${vgPrefix}-var";
        fsType = "ext4";
        neededForBoot = true; # mount early for passwd provisioning
        options = [ "nodev" "nosuid" "noexec" ];
      };

    "/var/lib/private/octoprint" = {
      device = "${vgPrefix}-var--lib--private--octoprint";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
    };

    "/var/lib/prometheus2" =
      {
        device = "${vgPrefix}-var--lib--prometheus2";
        fsType = "ext4";
        options = [ "nodev" "nosuid" "noexec" ];
      };

    "/var/log" =
      {
        device = "${vgPrefix}-var--log";
        fsType = "ext4";
        options = [ "nodev" "nosuid" "noexec" ];
      };

    # "/mnt/sdcard/eosr6" = {
    #   device = "/dev/disk/by-label/EOS_DIGITAL";
    #   fsType = "exfat";
    #   options = [ "nofail" "noauto" "x-systemd.automount" "x-systemd.idle-timeout=1min" "x-systemd.device-timeout=1ms" "nodev" "nosuid" "noexec" ];
    # };
  };

  swapDevices =
    [
      { device = "${vgPrefix}-swap"; }
    ];

  powerManagement.cpuFreqGovernor = "schedutil";
  networking.hostId = "1591AF90"; # required for zfs
}
