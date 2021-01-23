{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/apu2.nix>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # required for wifi interface
  ];

  boot.supportedFilesystems = [ "btrfs" ];

  fileSystems."/" = {
    device = "/dev/vg/root";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/vg/home";
    fsType = "ext4";
  };

  fileSystems."/nix" =
    {
      device = "/dev/vg/nix";
      fsType = "ext4";
    };

  fileSystems."/var" = {
    device = "/dev/vg/var";
    fsType = "ext4";
  };


  fileSystems."/var/log" = {
    device = "/dev/vg/var-log";
    fsType = "ext4";
  };

  fileSystems."/var/src" =
    {
      device = "/dev/vg/var-src";
      fsType = "ext4";
    };

  fileSystems."/data" = {
    device = "/dev/disk/by-id/ata-CT2000MX500SSD1_2048E4D39634-part1";
    fsType = "btrfs";
    options = [ "ssd" "space_cache" "subvolid=5" "subvol=/" "compress=zstd" ];
  };

  swapDevices =
    [
      { device = "/dev/vg/swap"; }
    ];
}
