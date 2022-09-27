_:
let
  disk = "/dev/disk/by-id/nvme-Force_MP600_192482300001285612C9";
  vgPrefix = "/dev/sysVG";
in
{
  imports = [
    ./config.nix
    ../../2configs/hw/ws2019
  ];

  system.stateVersion = "19.09";

  boot.initrd.luks.devices = {
    p4 = {
      device = "${disk}-part4";
    };

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
      options = [ "nodev" "nosuid" ];
    };

  fileSystems."/nix" =
    {
      device = "${vgPrefix}/nix";
      fsType = "ext4";
      options = [ "nodev" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/persist" =
    {
      device = "${vgPrefix}/persist";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/var/src" =
    {
      device = "${vgPrefix}/var-src";
      fsType = "ext4";
      options = [ "nodev" "nosuid" "noexec" ];
      neededForBoot = true; # mount early for passwd provisioning
    };

  fileSystems."/var/lib/docker" =
    {
      device = "${vgPrefix}/var-lib-docker";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/var/lib/libvirt/images" =
    {
      device = "${vgPrefix}/var-lib-libvirt-images";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/var/log" =
    {
      device = "${vgPrefix}/var-log";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  # 800M /var/log drive
  services.journald.extraConfig = ''
    SystemMaxUse=750M
    RuntimeMaxUse=750M
  '';

  fileSystems."/tmp" = {
    fsType = "tmpfs";
    options = [ "size=6G" "mode=1700" "nodev" "nosuid" ];
  };

  fileSystems."/boot" =
    {
      device = "${disk}-part1";
      fsType = "vfat";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  # fileSystems."/mnt/win" =
  #   {
  #     device = "${disk}-part4";
  #     fsType = "ntfs-3g";
  #     options = [ "nofail" "remove_hiberfile" "nodev" "nosuid" "noexec" ];
  #   };

  fileSystems."/mnt/luisa" =
    {
      device = "${vgPrefix}/luisa";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  fileSystems."/mnt/photos" =
    {
      device = "${vgPrefix}/photos";
      fsType = "ext4";
      options = [ "nofail" "nodev" "nosuid" "noexec" ];
    };

  swapDevices =
    [
      { device = "${vgPrefix}/swap"; }
    ];

  networking.hostId = "8c5598b5"; # required for zfs

  boot.kernelParams = [
    "systemd.machine_id=2e21667a3a1c4725ad5cda5326f1f46f"
    "mitigations=off" # make linux fast again
    "amd_iommu=on"
    "video=vesafb:off"
    "video=efifb:off"
  ];
}
