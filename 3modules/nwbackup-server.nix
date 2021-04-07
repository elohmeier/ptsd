{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwbackup-server;
  universe = import ../2configs/universe.nix;
  backupClients = filterAttrs (n: v: hasAttr "borg" v) universe.hosts;

  mkAuthorizedKey = name: client: key:
    let
      # Because of the following line, clients do not need to specify an absolute repo path
      cdCommand = "cd ${escapeShellArg "${cfg.mountRoot}/${name}/borg"}";
      restrictedArg = "--restrict-to-repository .";
      appendOnlyArg = "--append-only";
      quotaArg = optionalString (client.borg.quota != null) "--storage-quota ${client.borg.quota}";
      serveCommand = "borg serve ${restrictedArg} ${appendOnlyArg} ${quotaArg}";
    in
    ''command="${cdCommand} && ${serveCommand}",restrict ${key}'';

  sshPubKeys = import ../2configs/ssh-pubkeys.nix;

  mkUsersConfig = name: client: {
    users."borg-${name}" = {
      openssh.authorizedKeys.keys = map (mkAuthorizedKey name client) [ client.borg.pubkey sshPubKeys.sshPub.enno_yubi41 sshPubKeys.sshPub.enno_yubi49 ];
      useDefaultShell = true;
      group = "borg";
    };
    groups."borg" = { };
  };

  mkRepoService = name: client:
    nameValuePair "nwbackup-repo-${name}" {
      description = "Create BorgBackup repository ${name} directory";
      script = ''
        if ${pkgs.zfs}/bin/zfs list -H -o name | grep -q '^${cfg.zpool}${cfg.zfsPath}/${name}$'; then
          echo "zfs volume exists, skipping creation"
        else
          echo "creating zfs volume ${cfg.zpool}${cfg.zfsPath}/${name}"
          ${pkgs.zfs}/bin/zfs create ${cfg.zpool}${cfg.zfsPath}/${name}
        fi

        # set mountpoint causes remount, which fails when drive is in use.
        if [[ `${pkgs.zfs}/bin/zfs get mountpoint ${cfg.zpool}${cfg.zfsPath}/${name} -H -o value` == "${cfg.mountRoot}/${name}" ]]; then
          echo "mountpoint correctly set, skipping modification"
        else
          echo "setting mountpoint"
          ${pkgs.zfs}/bin/zfs set mountpoint=${cfg.mountRoot}/${name} ${cfg.zpool}${cfg.zfsPath}/${name}
        fi

        echo "setting quota"
        ${pkgs.zfs}/bin/zfs set quota=${client.borg.quota} ${cfg.zpool}${cfg.zfsPath}/${name}

        echo "creating borg directory"
        mkdir -p ${cfg.mountRoot}/${name}/borg
        chown -R borg-${name}:borg ${cfg.mountRoot}/${name}/borg
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };

  mkMigration = src: dest: ''
    if ${pkgs.zfs}/bin/zfs list -H -o name | grep -q '^${cfg.zpool}/${src}$'; then
      echo "nwbackup-server: migrating ${cfg.zpool}/${src}"
      ${pkgs.zfs}/bin/zfs set mountpoint=${cfg.mountRoot}/${dest} ${cfg.zpool}/${src}
      ${pkgs.zfs}/bin/zfs rename ${cfg.zpool}/${src} ${cfg.zpool}${cfg.zfsPath}/${dest}
    fi
  '';
in
{
  options = {
    ptsd.nwbackup-server = {
      enable = mkEnableOption "nwbackup borg repo server";
      zpool = mkOption {
        type = types.str;
        example = "nw27";
      };
      zfsPath = mkOption {
        type = types.str;
        default = "/backups";
        description = ''
          relative zfs-path (without zpool) to host the backups.
        '';
      };
      mountRoot = mkOption {
        type = types.path;
        default = "/mnt/backup";
      };
    };
  };

  config = mkIf cfg.enable {
    users = mkMerge (mapAttrsToList mkUsersConfig backupClients);
    environment.systemPackages = [ pkgs.borgbackup ];

    systemd.services = mapAttrs' mkRepoService backupClients;

    system.activationScripts.migrate-nwbackup =
      let
        migrations = {
          "eee1" = "eee1";
          "nw1" = "mb1";
          "nw10" = "nuc1";
          "nw11" = "apu1";
          "nw23" = "tp2";
          "nw30" = "tp1";
          "nw32" = "htz1";
          "nw34" = "apu2";
          "nw35" = "rpi2";
          "ws1" = "ws1";
        };
      in
      stringAfter [ "users" "groups" ] ''

      if ${pkgs.zfs}/bin/zfs list -H -o name | grep -q '^${cfg.zpool}${cfg.zfsPath}$'; then
        echo "nwbackup-server: zfs-root ${cfg.zpool}${cfg.zfsPath} exists, skipping creation"
      else
        echo "nwbackup-server: creating zfs-root ${cfg.zpool}${cfg.zfsPath}"
        ${pkgs.zfs}/bin/zfs create -o mountpoint=none ${cfg.zpool}${cfg.zfsPath}
      fi

      ${concatStringsSep "\n" (mapAttrsToList mkMigration migrations)}
    '';
  };
}
