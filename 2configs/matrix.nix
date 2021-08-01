{ config, lib, pkgs, ... }:
let
  matrixSecrets = import <secrets/matrix.nix>;
  serverName = "nerdworks.de";
  fqdn = "matrix.nerdworks.de";
in
{
  # https://github.com/tijder/SmsMatrix
  # https://github.com/tulir/gomuks

  services.matrix-synapse = {
    enable = true;
    # uncomment to register new users
    #registration_shared_secret = matrixSecrets.registration_shared_secret;
    server_name = serverName;
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
    app_service_config_files = [
      "/var/lib/matrix-synapse/telegram-registration.yaml"
    ];
    extraConfig = ''
      retention:
        enabled: true
        default_policy:
          min_lifetime: 1d
          max_lifetime: 30d
        purge_jobs:
          - longest_max_lifetime: 3d
            interval: 1d
          - shortest_max_lifetime: 3d
            interval: 1d
    '';
  };

  ptsd.secrets.files = {
    "mautrix-telegram.env" = {
      dependants = [ "mautrix-telegram.service" ];
    };
    "matrix-admin.env" = { };
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = config.ptsd.secrets.files."mautrix-telegram.env".path;
    settings = {
      homeserver = {
        address = "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.synapse}";
        domain = serverName;
      };

      bridge.permissions = {
        "${serverName}" = "full";
        "@enno:${serverName}" = "admin";
      };
    };
  };

  # ptsd.mautrix-whatsapp = {
  #   enable = true;
  #   settings = {
  #     homeserver = {
  #       address = "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.synapse}";
  #       domain = serverName;
  #     };
  #   };
  # };

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
      {
        name = "root";
        ensurePermissions."ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
      }
    ];
  };

  ptsd.nwtraefik.services = [
    {
      name = "synapse";
      rule = "Host(`${fqdn}`)";
      entryPoints = [
        "www4-http"
        "www4-https"
        "www6-http"
        "www6-https"
        "loopback4-https" # required for matrix-cleanup
      ];
    }
  ];

  systemd.services.matrix-cleanup = {
    description = "Cleanup matrix media files";
    script = ''
      ${pkgs.curl}/bin/curl -H "Authorization: Bearer $ACCESS_TOKEN" -X POST \
        https://${fqdn}/_synapse/admin/v1/media/${serverName}/delete\?before_ts=$(date +%s000 --date '30 days ago')
    '';
    startAt = "daily";

    serviceConfig = {
      EnvironmentFile = config.ptsd.secrets.files."matrix-admin.env".path;
      Restart = "on-failure";
      Type = "oneshot";

      DynamicUser = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "noaccess";
      RestrictNamespaces = true;
      DevicePolicy = "closed";
      RestrictRealtime = true;
      SystemCallFilter = "@system-service";
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";
      UMask = "0066";
      IPAddressDeny = "any";
      IPAddressAllow = "localhost";
    };
  };
}
