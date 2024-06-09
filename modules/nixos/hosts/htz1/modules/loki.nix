{ config, ... }:

let
  universe = import ../../../../common/universe.nix;
in
{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false; # single-tenant mode

      server = {
        http_listen_address = universe.hosts."${config.networking.hostName}".nets.tailscale.ip4.addr;
        http_listen_port = config.ptsd.ports.loki;
        log_level = "info";
      };

      common = {
        path_prefix = config.services.loki.dataDir;
        replication_factor = 1;
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
      };

      schema_config.configs = [
        {
          from = "2020-05-15";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config = {
        filesystem = {
          directory = "${config.services.loki.dataDir}/chunks";
        };
      };

      analytics.reporting_enabled = false;
    };
  };
}
