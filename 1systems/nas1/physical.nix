let
  disk = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_120GB_S21UNXAGB12736P";
  vgPrefix = "/dev/disk/by-id/dm-name-sysVG";
in
{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/nas2020.nix>
  ];

  system.stateVersion = "19.09";

  boot.initrd.luks.devices.sysVG = {
    device = "${disk}-part2";
  };

  fileSystems."/" =
    {
      device = "${vgPrefix}-root";
      fsType = "ext4";
    };

  fileSystems."/home" =
    {
      device = "${vgPrefix}-home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}-nix";
      fsType = "ext4";
    };

  fileSystems."/var" =
    {
      device = "${vgPrefix}-var";
      fsType = "ext4";
    };

  fileSystems."/var/log" =
    {
      device = "${vgPrefix}-var--log";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "${disk}-part1";
      fsType = "vfat";
    };

  swapDevices =
    [
      { device = "${vgPrefix}-swap"; }
    ];

  networking.hostId = "1591AF90"; # required for zfs

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.cpuFreqGovernor = "powersave";
}
