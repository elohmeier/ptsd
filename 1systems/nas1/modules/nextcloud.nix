{ config, lib, pkgs, ... }:

with lib;
let
  domain = "nextcloud.services.nerdworks.de";
  nextcloudUid = 131; # unused as of 19.09, old docker uid
in
{
  services.postgresql.ensureDatabases = [ "nextcloud" ];
  services.postgresql.ensureUsers = [
    {
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }
  ];

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  users.groups.keys.members = [ "nextcloud" ];

  ptsd.secrets.files."ncadmin-pw" = {
    owner = "nextcloud";
    group-name = "nextcloud";
    dependants = [ "nextcloud-setup.service" ];
  };

  # this is not set inside nixpkgs for NextCloud as of 19.09
  users.users.nextcloud = {
    isSystemUser = true;
    uid = nextcloudUid;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud22;
    hostName = domain;
    https = true;
    caching = {
      apcu = true;
      redis = true;
      memcached = false;
    };
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminuser = "ncadmin";
      adminpassFile = config.ptsd.secrets.files."ncadmin-pw".path;
      trustedProxies = [ "127.0.0.1" ];
    };
  };

  services.nginx.virtualHosts."${domain}".listen = [
    {
      addr = "127.0.0.1";
      port = config.ptsd.ports.nextcloud;
    }
  ];

  services.redis = {
    enable = true; # remember to activate it in the local NextCloud config file!
  };

  ptsd.nwtraefik = {
    middlewares."nextcloud-redirectregex" =
      {
        redirectRegex = {
          permanent = true;
          regex = "https://(.*)/.well-known/(card|cal)dav";
          replacement = ''https://''${1}/remote.php/dav/'';
        };
      };

    services = [
      {
        name = "nextcloud";
        rule = "Host(`${domain}`)";
        extraMiddlewares = [ "nextcloud-redirectregex" ];
        entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
      }
    ];
  };

}
