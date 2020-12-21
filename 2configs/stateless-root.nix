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
    "nwbackup.id_ed25519" = {
      path = "/root/.ssh/id_ed25519";
    };
  };

  security.dhparams.path = "/persist/var/lib/dhparams";

  environment.etc = lib.optionalAttrs config.networking.networkmanager.enable {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/acme - - - - /persist/var/lib/acme"
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/libvirt/qemu - - - - /persist/var/lib/libvirt/qemu"
  ];

  fileSystems = {
    "/var/lib/systemd" = {
      device = "/persist/var/lib/systemd";
      options = [ "bind" ];
    };
    "/var/lib/systemd/coredump" =
      {
        fsType = "tmpfs";
        options = [ "size=100M" "mode=1644" ];
      };
  } // lib.optionalAttrs config.services.samba.enable {
    "/var/lib/samba" =
      {
        device = "/persist/var/lib/samba";
        options = [ "bind" ];
      };
  };

  system.activationScripts.initialize-persist-drive = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /persist/etc/NetworkManager/system-connections/
    mkdir -p /persist/var/cache/borg
    mkdir -p /persist/var/lib/acme
    mkdir -p /persist/var/lib/bluetooth
    mkdir -p /persist/var/lib/libvirt/qemu
    mkdir -p /persist/var/lib/samba
    mkdir -p /persist/var/lib/systemd
  '';
}
