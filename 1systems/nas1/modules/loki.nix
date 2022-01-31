{ config, lib, pkgs, ... }:

let
  port = 7411;
in
{
  services.loki = {
    enable = true;
    # https://grafana.com/docs/loki/latest/configuration/examples/
    configuration = {
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = config.ptsd.ports.loki;
      };
      auth_enabled = false; # single-tenant mode
      schema_config = {
        configs = [
          {
            from = "2021-01-01";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index.prefix = "index_";
            index.period = "24h";
          }
        ];
      };
      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper/active";
          cache_location = "/var/lib/loki/boltdb-shipper/cache";
          cache_ttl = "24h";
          shared_store = "filesystem";

        };
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };

      ingester = {
        lifecycler = {
          interface_names = [ "lo" ];
          address = "127.0.0.1";

          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
      };
      compactor = {
        shared_store = "filesystem";
        compaction_interval = "10m";
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        retention_delete_delay = "168h"; # 7d
        retention_delete_worker_count = 150;
      };
    };
  };

  systemd.services.traefik.serviceConfig.LoadCredential = "loki.htpasswd:/var/src/secrets/loki.htpasswd";

  ptsd.nwtraefik = {
    entryPoints = {
      nwvpn-loki-http = {
        address = "${config.ptsd.wireguard.networks.nwvpn.ip}:${toString port}";
      };
    };
    middlewares = {
      loki-auth.basicAuth = {
        usersFile = "/run/credentials/traefik.service/loki.htpasswd";
        realm = "loki";
      };
    };

    services = [{
      name = "loki";
      entryPoints = [ "nwvpn-loki-http" ];
      rule = "Host(`${config.ptsd.wireguard.networks.nwvpn.ip}`)";
      tls = false;
      extraMiddlewares = [ "loki-auth" ];
    }];
  };

  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ port ];
}
