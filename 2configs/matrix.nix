{ config, lib, pkgs, ... }:
let
  matrixSecrets = import <secrets/matrix.nix>;
in
{
  services.matrix-synapse = {
    enable = true;
    # uncomment to register new users
    #registration_shared_secret = matrixSecrets.registration_shared_secret;
    server_name = "nerdworks.de";
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

  ptsd.secrets.files = {
    "mautrix-telegram.env" = {
      dependants = [ "mautrix-telegram.service" ];
    };
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = config.ptsd.secrets.files."mautrix-telegram.env".path;
    settings = {
      homeserver = {
        address = "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.synapse}";
        domain = "nerdworks.de";
      };

      bridge.permissions = {
        "nerdworks.de" = "full";
        "@enno:nerdworks.de" = "admin";
      };
    };
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

  ptsd.nwtraefik.services = [
    {
      name = "synapse";
      rule = "Host(`matrix.nerdworks.de`)";
    }
  ];
}
