{ config, lib, pkgs, ... }:
{
  ptsd.nwbackup = {
    cacheDir = "/persist/var/cache/borg";
    paths = [
      "/home"
      "/persist"
    ];
  };

  ptsd.secrets.files = lib.optionalAttrs config.ptsd.nwbackup.enable {
    "nwbackup_id_ed25519" = {
      path = "/root/.ssh/id_ed25519";
    };
  };

  ptsd.lego.home = "/persist/var/lib/lego";

  environment.etc = lib.optionalAttrs config.networking.networkmanager.enable {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/libvirt/qemu - - - - /persist/var/lib/libvirt/qemu"
  ];

  fileSystems = lib.optionalAttrs config.services.samba.enable {
    "/var/lib/samba" =
      {
        device = "/persist/var/lib/samba";
        options = [ "bind" ];
      };
  };
}
