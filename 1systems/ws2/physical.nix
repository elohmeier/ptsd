{ ... }:

{
  imports = [
    ./config.nix
    ../../2configs/hw/ws2021.nix
  ];

  system.stateVersion = "21.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    luks.devices = {
      cryptlvm = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNMFN904187J-part2";
      };
    };
  };

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "size=200M" "mode=1755" ];
  };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNMFN904187J-part1";
      fsType = "vfat";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/sysVG/home";
      fsType = "ext4";
      options = [ "nodev" "nosuid" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/sysVG/nix";
      fsType = "ext4";
      options = [ "nodev" ];
    };

  fileSystems."/persist" =
    {
      device = "/dev/sysVG/persist";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/var/src" = {
    device = "/dev/sysVG/var-src";
    fsType = "ext4";
    options = [ "nodev" "nosuid" "noexec" ];
    neededForBoot = true; # mount early for passwd provisioning
  };

  fileSystems."/var/log" =
    {
      device = "/dev/sysVG/var-log";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  # 800M /var/log drive
  services.journald.extraConfig = ''
    SystemMaxUse=750M
    RuntimeMaxUse=750M
  '';

  boot.kernelParams = [
    "mitigations=off" # make linux fast again
    "systemd.machine_id=78a79fa3b73e4177a65efe6e9be87e68"
  ];
}
