{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraamdb;
  gitRef = (lib.importJSON ./fraamdb.json);
  src =
    if cfg.devSrc == "" then
      pkgs.fetchgit
        {
          url = "https://git.fraam.de/fraam/fraamdb.git";
          rev = "refs/tags/${gitRef.version}";
          sha256 = gitRef.sha256;
        } else pkgs.nix-gitignore.gitignoreSourcePure [ "${cfg.devSrc}/.gitignore" ] cfg.devSrc;
  fraamdb = pkgs.callPackage (src) { };
  pyenv = fraamdb.dependencyEnv; # gunicorn is included in project dependencies
  manage = pkgs.writeShellScript "fraamdb-manage" ''
    export DJANGO_SETTINGS_MODULE="fraamdb.settings";    
    export DATABASE_URL="sqlite:////var/lib/fraamdb/fraamdb.sqlite";
    ${pyenv}/bin/manage.py ''${@:1}
  '';
in
{
  # run `/var/lib/fraamdb/manage createsuperuser` as root to create an admin user

  options = {
    ptsd.fraamdb = {
      enable = mkEnableOption "fraamdb";
      domain = mkOption {
        type = types.str;
        default = "localhost";
      };
      entryPoints = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      devSrc = mkOption {
        type = types.str;
        default = "";
        example = "/home/enno/repos/fraamdb";
      };
      debug = mkEnableOption "debug";
      httpsOnly = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.fraamdb = {
      description = "fraamdb django app";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      environment = {
        DJANGO_SETTINGS_MODULE = "fraamdb.settings";
        PYTHONPATH = "${pyenv}/${pyenv.python.sitePackages}/";
        DATABASE_URL = "sqlite:////var/lib/fraamdb/fraamdb.sqlite";
        ALLOWED_HOSTS = cfg.domain;
        STATIC_ROOT = fraamdb.static;
        DEBUG = if cfg.debug then "1" else "0";
        HTTPS_ONLY = if cfg.httpsOnly then "1" else "0";
      };

      preStart = ''
        if [[ $(readlink /var/lib/fraamdb/manage) != "${manage}" ]]; then
          ln -sf "${manage}" /var/lib/fraamdb/manage
        fi
      '';

      script = ''
        ${pyenv}/bin/manage.py migrate
        ${pyenv}/bin/gunicorn fraamdb.wsgi \
          -b 127.0.0.1:${toString config.ptsd.nwtraefik.ports.fraamdb} \
          --workers=2 \
          --threads=2
      '';

      serviceConfig = {
        EnvironmentFile = "/var/src/secrets/fraamdb.env";
        DynamicUser = true;
        User = "fraamdb"; # needs to be set for shared uid
        CapabilityBoundingSet = "cap_net_bind_service";
        LockPersonality = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        NoNewPrivileges = true;
        StateDirectory = "fraamdb";
      };
    };

    systemd.services.fraamdb-importtimesheets = {
      description = "fraamdb import timesheets";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      environment = {
        DJANGO_SETTINGS_MODULE = "fraamdb.settings";
        PYTHONPATH = "${pyenv}/${pyenv.python.sitePackages}/";
        DATABASE_URL = "sqlite:////var/lib/fraamdb/fraamdb.sqlite";
      };

      preStart = ''
        if [[ $(readlink /var/lib/fraamdb/manage) != "${manage}" ]]; then
          ln -sf "${manage}" /var/lib/fraamdb/manage
        fi
      '';

      script = ''
        ${pyenv}/bin/manage.py migrate
        ${pyenv}/bin/manage.py importtimesheets 3
        ${pyenv}/bin/manage.py updatebalances
        ${pyenv}/bin/manage.py updatepnsquotas
      '';

      serviceConfig = {
        DynamicUser = true;
        User = "fraamdb"; # needs to be set for shared uid
        NoNewPrivileges = true;
        LockPersonality = true;
        StateDirectory = "fraamdb";
      };

      startAt = "*-*-* 06:00:00";
    };

    ptsd.nwtraefik.services = mkIf (cfg.entryPoints != [ ]) [
      {
        name = "fraamdb";
        rule = "Host(`${cfg.domain}`)";
        auth.forwardAuth = {
          address = "http://localhost:4181";
          authResponseHeaders = [ "X-Forwarded-User" ];
        };
        entryPoints = cfg.entryPoints;
      }
    ];
  };
}