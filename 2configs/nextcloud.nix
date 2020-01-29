{ config, lib, pkgs, ... }:

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

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.services.nerdworks.de";
    https = true;
    nginx.enable = true;
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
      adminpassFile = (toString <secrets>) + "/ncadmin-pw";
    };
  };

  services.nginx.virtualHosts."nextcloud.services.nerdworks.de".listen = [
    {
      addr = "127.0.0.1";
      port = 1082;
    }
  ];

  services.redis = {
    enable = true;
  };

}
