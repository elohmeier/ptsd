{ config, lib, pkgs, ... }:

let
  genUnlock = name: {
    description = "Unlock vg/${name}";
    unitConfig.ConditionPathExists = "/run/keys/${name}.luks";
    script = ''
      # if the volume is already unlocked, exit
      if test -e "/dev/mapper/${name}"; then
        exit 0
      fi

      echo "Unlocking vg/${name} with keyfile"
      cat "/run/keys/${name}.luks" | ${pkgs.cryptsetup}/bin/cryptsetup luksOpen "/dev/vg/${name}" "${name}" -
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    requires = [ "lv-activate-${name}.service" ];
    after = [ "lv-activate-${name}.service" ];
  };

  lvActivate = name: {
    description = "Activate vg/${name}";
    script = ''
      ${pkgs.lvm2.bin}/bin/lvchange -ay "vg/${name}"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
in
{
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "size=1G" "mode=1755" ];
  };

  fileSystems."/nix" = {
    device = "/dev/vg/nix";
    fsType = "ext4";
    neededForBoot = true;
    options = [ "nodev" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A3C8-1710";
    fsType = "vfat";
    options = [ "nofail" "nodev" "nosuid" "noexec" ];
  };

  systemd.mounts =
    let
      borgDeps = [
        "borgbackup-repo-apu2.service"
        "borgbackup-repo-htz1.service"
        "borgbackup-repo-htz2.service"
        "borgbackup-repo-htz3.service"
        "borgbackup-repo-mb3.service"
        "borgbackup-repo-mb4.service"
        "borgbackup-repo-bae0thiu.service"
      ];
      hassDeps = [
        "home-assistant.service"
      ];
      syncthingDeps = [
        "icloudpd-enno.service"
        "icloudpd-luisa.service"
        "rclone-fraam-gdrive-backup.service"
        "samba-smbd.service"
        "syncthing.service"
        "syncthing-init.service"
        "photoprism.service"
      ];
      photoprismDeps = [
        "photoprism.service"
      ];
    in
    [
      {
        what = "/dev/vg/borgbackup";
        where = "/srv/borgbackup";
        type = "ext4";
        options = "noatime,nofail,nodev,nosuid,noexec";
        before = borgDeps;
        requiredBy = borgDeps;
        requires = [ "lv-activate-borgbackup.service" ];
        after = [ "lv-activate-borgbackup.service" ];
      }
      {
        what = "/dev/vg/hass";
        where = "/var/lib/hass";
        type = "ext4";
        options = "noatime,nofail,nodev,nosuid,noexec";
        before = hassDeps;
        requiredBy = hassDeps;
        requires = [ "lv-activate-hass.service" ];
        after = [ "lv-activate-hass.service" ];
      }
      {
        what = "/dev/mapper/syncthing";
        where = "/var/lib/syncthing";
        type = "ext4";
        options = "noatime,nofail,nodev,nosuid,noexec";
        before = syncthingDeps;
        requiredBy = syncthingDeps;
        requires = [ "unlock-syncthing.service" ];
        after = [ "unlock-syncthing.service" ];
      }
      {
        what = "/dev/mapper/photoprism";
        where = "/var/lib/photoprism";
        type = "ext4";
        options = "noatime,nofail,nodev,nosuid,noexec";
        before = photoprismDeps;
        requiredBy = photoprismDeps;
      }
      {
        what = "/dev/mapper/mysql";
        where = "/var/lib/mysql";
        type = "ext4";
        options = "noatime,nofail,nodev,nosuid,noexec";
        before = [ "mysql.service" ];
        requiredBy = [ "mysql.service" ];
      }
    ];

  systemd.services.mysql.wantedBy = lib.mkForce [ ];
  systemd.services.photoprism.wantedBy = lib.mkForce [ ];
  systemd.services.prometheus-mysqld-exporter.wantedBy = lib.mkForce [ ];
  systemd.services.samba-smbd.wantedBy = lib.mkForce [ ];
  systemd.services.syncthing-init.wantedBy = lib.mkForce [ ];
  systemd.services.syncthing.wantedBy = lib.mkForce [ ];

  systemd.targets.unlock-disks = {
    description = "Unlock /mnt";
    requires = [
      "unlock-mysql.service"
      "unlock-photoprism.service"
      "unlock-syncthing.service"
    ];
    wants = [
      "mysql.service"
      "photoprism.service"
      "prometheus-mysqld-exporter.service"
      "samba-smbd.service"
      "syncthing-init.service"
      "syncthing.service"
    ];
  };

  systemd.services.unlock-mysql = genUnlock "mysql";
  systemd.services.unlock-photoprism = genUnlock "photoprism";
  systemd.services.unlock-syncthing = genUnlock "syncthing";

  systemd.services.lv-activate-borgbackup = lvActivate "borgbackup";
  systemd.services.lv-activate-hass = lvActivate "hass";
  systemd.services.lv-activate-mysql = lvActivate "mysql";
  systemd.services.lv-activate-photoprism = lvActivate "photoprism";
  systemd.services.lv-activate-syncthing = lvActivate "syncthing";
}
