{ config, ... }:
let
  disk = "/dev/disk/by-id/nvme-Force_MP600_192482300001285612C9";
  vgPrefix = "/dev/p5vg";
in
{
  imports = [
    ./config.nix
    ../../2configs/hw/ws2019.nix
    ../../2configs/luks-ssh-unlock.nix
  ];

  # fix often full /boot directory
  boot.loader.systemd-boot.configurationLimit = 2;

  system.stateVersion = "19.09";

  boot.initrd.luks.devices = {
    p5 = {
      device = "${disk}-part5";
    };

    # usbssd = {
    #   device = "/dev/disk/by-id/usb-Inateck_NS1066_0123456789ABCDE-0:0-part1";
    #   preLVM = false;
    #   keyFile = "${vgPrefix}-usbssdkey";
    #   keyFileSize = 4096;
    #   fallbackToPassword = true;
    # };
  };

  fileSystems."/" =
    {
      fsType = "tmpfs";
      options = [ "size=2G" "mode=1755" ];
    };

  fileSystems."/home" =
    {
      device = "${vgPrefix}/home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}/nix";
      fsType = "ext4";
    };

  fileSystems."/persist" =
    {
      device = "${vgPrefix}/persist";
      fsType = "ext4";
    };

  fileSystems."/var/src" =
    {
      device = "${vgPrefix}/var-src";
      fsType = "ext4";
      neededForBoot = true; # mount early for passwd provisioning
    };

  fileSystems."/var/lib/docker" =
    {
      device = "${vgPrefix}/var-lib-docker";
      fsType = "ext4";
    };

  fileSystems."/var/lib/libvirt/images" =
    {
      device = "${vgPrefix}/var-lib-libvirt-images";
      fsType = "ext4";
    };

  fileSystems."/var/log" =
    {
      device = "${vgPrefix}/var-log";
      fsType = "ext4";
    };

  # 800M /var/log drive
  services.journald.extraConfig = ''
    SystemMaxUse=750M
    RuntimeMaxUse=750M
  '';

  fileSystems."/boot" =
    {
      device = "${disk}-part2";
      fsType = "vfat";
    };

  fileSystems."/mnt/win" =
    {
      device = "${disk}-part4";
      fsType = "ntfs-3g";
      options = [ "nofail" "remove_hiberfile" ];
    };

  swapDevices =
    [
      { device = "${vgPrefix}/swap"; }
    ];

  networking.hostId = "8c5598b5"; # required for zfs
  boot.kernelParams = [ "systemd.machine_id=2e21667a3a1c4725ad5cda5326f1f46f" ];
}
