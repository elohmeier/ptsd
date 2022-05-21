{ config, lib, pkgs, ... }:
{
  ptsd.nwbackup = {
    cacheDir = "/persist/var/cache/borg";
    extraPaths = [
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
    "/var/lib/tailscale" = {
      device = "/persist/var/lib/tailscale";
      options = [ "bind" ];
    };
  };

  systemd.mounts = lib.optionals config.services.samba.enable [
    {
      what = "/persist/var/lib/samba";
      where = "/var/lib/samba";
      type = "none";
      options = "bind";
      before = [ "samba-nmbd.service" "samba-smbd.service" "samba-winbindd.service" ];
      requiredBy = [ "samba-nmbd.service" "samba-smbd.service" "samba-winbindd.service" ];
    }
  ];

  system.activationScripts.initialize-persist-drive = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /persist/etc/NetworkManager/system-connections/
    mkdir -p /persist/var/cache/borg
    mkdir -p /persist/var/lib/acme
    mkdir -p /persist/var/lib/bluetooth
    mkdir -p /persist/var/lib/libvirt/qemu
    mkdir -p /persist/var/lib/samba/private
    mkdir -p /persist/var/lib/systemd
    mkdir -p /persist/var/lib/tailscale
  '';
}
