{ config, pkgs, ... }:

{
  systemd.services.photoprism = {
    description = "Photoprism Photo Management";
    after = [ "network.target" "mysql.service" ];
    wants = [ "network.target" "mysql.service" ];

    script = ''
      PWFILE=/var/lib/photoprism/.initial-password.txt

      if [ ! -f $PWFILE ]; then
        ${pkgs.pwgen}/bin/pwgen -s 32 1 > $PWFILE
      fi

      ${pkgs.photoprism}/bin/photoprism \
        --sponsor \
        --admin-password $(cat $PWFILE) \
        start
    '';

    environment = {
      PHOTOPRISM_HTTP_HOST = "127.0.0.1";
      PHOTOPRISM_HTTP_PORT = toString config.ptsd.ports.photoprism;
      PHOTOPRISM_SITE_CAPTION = "PhotoPrism";
      PHOTOPRISM_SITE_URL = "https://rpi4.pug-coho.ts.net:2342/";
      PHOTOPRISM_TRUSTED_PROXY = "127.0.0.0/8";

      PHOTOPRISM_CACHE_PATH = "/var/lib/photoprism/cache";
      PHOTOPRISM_IMPORT_PATH = "/var/lib/syncthing/photos/import";
      PHOTOPRISM_ORIGINALS_PATH = "/var/lib/syncthing/photos/originals";
      PHOTOPRISM_STORAGE_PATH = "/var/lib/photoprism/storage";

      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "syncthing";
    };

    serviceConfig = {
      User = "syncthing";
      Group = "syncthing";

      # indexing should be done in the background
      # might be better to split indexing and serving into two services for different priorities
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };

  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    ensureDatabases = [ "photoprism" ];
    ensureUsers = [
      {
        name = "syncthing";
        ensurePermissions = {
          "photoprism.*" = "ALL PRIVILEGES";
        };
      }
      {
        name = "prometheus-mysqld-exporter";
        ensurePermissions = {
          "*.*" = "PROCESS, REPLICATION CLIENT, SELECT, SLAVE MONITOR";
        };
      }
    ];
  };

  users.groups.prometheus-mysqld-exporter = { };
  users.users.prometheus-mysqld-exporter = {
    isSystemUser = true;
    group = "prometheus-mysqld-exporter";
  };

  systemd.services.prometheus-mysqld-exporter =
    let
      my-cnf = pkgs.writeText "my.cnf" ''
        [client]
        user = prometheus-mysqld-exporter
        password = socket-authenticated...
        socket = /run/mysqld/mysqld.sock
      '';
    in
    {
      description = "Prometheus MySQL Exporter";
      after = [ "network.target" "mysql.service" ];
      wants = [ "network.target" "mysql.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.prometheus-mysqld-exporter}/bin/mysqld_exporter --config.my-cnf ${my-cnf} --web.listen-address :${toString config.ptsd.ports.prometheus-mysqld}";
        User = "prometheus-mysqld-exporter";
        Group = "prometheus-mysqld-exporter";
      };
    };
}
