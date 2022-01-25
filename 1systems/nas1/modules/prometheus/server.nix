{ config, lib, pkgs, ... }:

with lib;
let
  universe = import ../../../../2configs/universe.nix;
  vpnNodes = netname: filterAttrs (hostname: hostcfg: hostname != config.networking.hostName && hasAttrByPath [ "nets" netname ] hostcfg) universe.hosts;
  blackboxGenericScrapeConfig = {
    scrape_interval = "60s";
    metrics_path = "/probe";
    relabel_configs = [
      {
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      }
      {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }
      {
        target_label = "__address__";
        replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
      }
    ];
  };

  nwJob = host: unit: exporter: alwayson: {
    job_name = "${exporter}_${host}_${unit}";
    scrape_interval = "60s";
    metrics_path = "/${unit}/${exporter}/metrics";
    static_configs = [{
      targets = [
        "${universe.hosts."${host}".nets.nwvpn.ip4.addr}:9100"
      ];
      labels = {
        alias = if host == unit then host else "${host}-${unit}";
        alwayson = if alwayson then "1" else "0";
      };
    }];
  };

in
{
  users.groups.keys.members = [ "prometheus" ];

  ptsd.secrets.files."hass-token-nas1-prometheus" = {
    dependants = [ "prometheus.service" ];
    owner = "prometheus";
  };

  services.prometheus = {
    enable = true;
    checkConfig = false; # disabled because of potentially missing secret files (e.g. bearer_token_file) at build time
    port = config.ptsd.ports.prometheus-server;
    extraFlags = [
      "--storage.tsdb.retention.time 720h" # 30d
    ];

    scrapeConfigs = [
      {
        job_name = "hass";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        bearer_token_file = config.ptsd.secrets.files."hass-token-nas1-prometheus".path;
        scheme = "https";
        static_configs = [{
          targets = [
            "hass.services.nerdworks.de"
          ];
        }];
      }
      {
        job_name = "fritzbox";
        scrape_interval = "60s";
        static_configs = [{
          targets = [
            "127.0.0.1:9787"
          ];
        }];
      }
      {
        job_name = "quotes";
        scrape_interval = "60s";
        metrics_path = "/price";
        params.symbols = lib.importJSON ./securities.json;
        #params.symbols = [ (concatStringsSep "," (lib.importJSON ./securities.json)) ];
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.ptsd.ports.prometheus-quotes-exporter}"
          ];
        }];
      }
      {
        job_name = "node";
        scrape_interval = "60s";

        # scrape all nwvpn hosts
        static_configs = (
          mapAttrsToList
            (
              hostname: hostcfg: {
                targets = [
                  "${hostcfg.nets.nwvpn.ip4.addr}:9100"
                ];
                labels = {
                  alias = hostname;
                  alwayson = if hostname == "mb1" then "0" else "1";
                };
              }
            )
            (filterAttrs (hostname: _: elem hostname [ "htz4" "wrt1" "wrt2" "mb1" ]) (vpnNodes "nwvpn"))
        );
      }

      (nwJob "apu2" "apu2" "node" true)
      (nwJob "eee1" "eee1" "node" false)
      (nwJob "htz1" "htz1" "node" true)
      (nwJob "htz2" "htz2" "node" true)
      (nwJob "htz2" "htz2" "maddy" true)
      (nwJob "htz3" "htz3" "node" true)
      (nwJob "htz3" "gitlab" "node" true)
      (nwJob "htz3" "wpjail" "node" true)
      (nwJob "nas1" "nas1" "node" true)
      (nwJob "ws1" "ws1" "node" false)
      (nwJob "ws2" "ws2" "node" false)
      (nwJob "tp1" "tp1" "node" false)

      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_2xx";
        params.module = [ "http_2xx" ];
        static_configs = [
          {
            targets = [
              # TODO: unsilence
              #"https://octoprint.services.nerdworks.de"
              "https://vault.fraam.de"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_acme_dns";
        params.module = [ "http_acme_dns" ];
        static_configs = [
          {
            targets = [
              "https://auth.nerdworks.de/update"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_fraam_www";
        params.module = [ "http_fraam_www" ];
        static_configs = [
          {
            targets = [
              "https://www.fraam.de"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_nerdworks_www";
        params.module = [ "http_nerdworks_www" ];
        static_configs = [
          {
            targets = [
              "https://www.nerdworks.de"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_grafana";
        params.module = [ "http_grafana" ];
        static_configs = [
          {
            targets = [
              "https://grafana.services.nerdworks.de/login"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_nextcloud";
        params.module = [ "http_nextcloud" ];
        static_configs = [
          {
            targets = [
              "https://nextcloud.services.nerdworks.de/login"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_home_assistant";
        params.module = [ "http_home_assistant" ];
        static_configs = [
          {
            targets = [
              "https://hass.services.nerdworks.de"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_monica";
        params.module = [ "http_monica" ];
        static_configs = [
          {
            targets = [
              "https://monica.services.nerdworks.de"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_gitea";
        params.module = [ "http_gitea" ];
        static_configs = [
          {
            targets = [
              "https://git.nerdworks.de"
            ];
          }
        ];
      })
      # (blackboxGenericScrapeConfig // {
      #   job_name = "blackbox_http_drone";
      #   params.module = [ "http_drone" ];
      #   static_configs = [
      #     {
      #       targets = [
      #         "https://ci.nerdworks.de"
      #       ];
      #     }
      #   ];
      # })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_gitlab";
        params.module = [ "http_gitlab" ];
        static_configs = [
          {
            targets = [
              "https://git.fraam.de"
            ];
          }
        ];
      })
    ];
  };

  ptsd.nwtraefik = {
    services = [
      {
        name = "prometheus-server";
        entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
        rule = "Host(`prometheus.services.nerdworks.de`)";
      }
    ];
  };
}
