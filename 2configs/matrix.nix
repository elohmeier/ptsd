{ config, lib, pkgs, ... }:

let
  domain = "matrix.nerdworks.de";
in
{
  services.matrix-synapse = {
    enable = true;
    server_name = domain;
    database_type = "psycopg2";
    database_args = {
      dbname = "synapse";
    };
    listeners = [
      {
        port = config.ptsd.nwtraefik.ports.synapse;
        bind_address = "127.0.0.1";
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [
          {
            names = [ "client" "federation" ];
            compress = false;
          }
        ];
      }
    ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE DATABASE "synapse"
        ENCODING "UTF-8"
        LC_COLLATE = "C"
        LC_CTYPE = "C"
        TEMPLATE template0;
    '';
    ensureUsers = [
      {
        name = "matrix-synapse"; # must match service user
        ensurePermissions."DATABASE synapse" = "ALL PRIVILEGES";
      }
    ];
  };
}
