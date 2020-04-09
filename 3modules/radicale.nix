{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.radicale;

  confFile = pkgs.writeText "radicale.conf" (
    generators.toINI {} {
      server = {
        hosts = "127.0.0.1:${toString cfg.port}";
      };

      auth = {
        type = "htpasswd";
        htpasswd_filename = cfg.htpasswd;
        htpasswd_encryption = "bcrypt";
      };

      storage = {
        filesystem_folder = "${cfg.dataDir}/collections";
        hook = ''${pkgs.git}/bin/git add -A && (git diff --cached --quiet || ${pkgs.git}/bin/git commit -m "Changes by "%(user)s)'';
      };

      logging = {
        debug = "true";
      };
    }
  );

  gitignore = pkgs.writeText "gitignore" ''
    .Radicale.cache
    .Radicale.lock
    .Radicale.tmp-*
  '';
in
{

  options = {
    ptsd.radicale = {
      enable = mkEnableOption "radicale";
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/radicale";
      };
      port = mkOption {
        type = types.int;
      };
      # generate using {pkgs.apacheHttpd}/bin/htpasswd -bcB "$out" USER PWD
      htpasswd = mkOption {
        type = types.path;
        description = "htpasswd authentication file, bcrypt encryption is expected";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.radicale2 pkgs.git ];

    users.users = singleton
      {
        name = "radicale";
        uid = config.ids.uids.radicale;
        description = "radicale user";
        home = cfg.dataDir;
        createHome = true;
        isSystemUser = true;
      };

    users.groups = singleton
      {
        name = "radicale";
        gid = config.ids.gids.radicale;
      };

    systemd.services.radicale = {
      description = "A Simple Calendar and Contact Server";
      after = [ "network.target" ];
      requires = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p "${cfg.dataDir}/collections"
        ${pkgs.git}/bin/git -C "${cfg.dataDir}/collections" init .
        ${pkgs.coreutils}/bin/cp ${gitignore} "${cfg.dataDir}/collections/.gitignore"
        ${pkgs.coreutils}/bin/chmod o+w "${cfg.dataDir}/collections/.gitignore"
      '';
      serviceConfig = {
        ExecStart = "${pkgs.radicale2}/bin/radicale -C ${confFile}";
        User = "radicale";
        Group = "radicale";
        Restart = "on-failure";
        # Deny other users access to the calendar data
        UMask = "0027";
        PrivateTmp = "true";
        ProtectSystem = "strict";
        ProtectHome = "true";
        PrivateDevices = "true";
        ProtectKernelTunables = "true";
        ProtectKernelModules = "true";
        ProtectControlGroups = "true";
        NoNewPrivileges = "true";
        ReadWritePaths = cfg.dataDir;
      };
    };
  };
}
