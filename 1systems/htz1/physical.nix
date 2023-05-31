_:
let
  vgPrefix = "/dev/disk/by-id/dm-name-vg";
in
{
  imports = [
    ./config.nix
    ../../2configs/nix-persistent.nix
    ../../2configs/hw/hetzner-vm.nix
    ../../2configs/luks-ssh-unlock.nix
  ];

  boot.initrd.luks.devices.root =
    {
      device = "/dev/sda2";
      preLVM = true;
    };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [ "size=1G" "mode=1755" ];
    };

    "/boot" = {
      device = "/dev/sda1";
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
        neededForBoot = true; # mount early for passwd provisioning
      };
  };

  swapDevices = [
    { device = "${vgPrefix}-swap"; }
  ];
}
