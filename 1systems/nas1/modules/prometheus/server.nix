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

  systemd.services.prometheus.serviceConfig.LoadCredential = [
    "hass-token-nas1-prometheus-bs53:/var/src/secrets/hass-token-nas1-prometheus-bs53"
    "hass-token-nas1-prometheus-dlrg:/var/src/secrets/hass-token-nas1-prometheus-dlrg"
  ];

  services.prometheus = {
    enable = true;
    checkConfig = false; # disabled because of potentially missing secret files (e.g. bearer_token_file) at build time
    listenAddress = "127.0.0.1";
    port = config.ptsd.ports.prometheus-server;
    extraFlags = [
      "--storage.tsdb.retention.time 720h" # 30d
    ];

    scrapeConfigs = [
      {
        job_name = "hass_bs53";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        bearer_token_file = "/run/credentials/prometheus.service/hass-token-nas1-prometheus-bs53";
        scheme = "https";
        static_configs = [{
          targets = [
            "hass.services.nerdworks.de"
          ];
        }];
      }
      {
        job_name = "hass_dlrg";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        bearer_token_file = "/run/credentials/prometheus.service/hass-token-nas1-prometheus-dlrg";
        scheme = "http";
        static_configs = [{
          targets = [
            "apu2.nw:8123"
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
            (filterAttrs (hostname: _: elem hostname [ "wrt1" "wrt2" "mb1" ]) (vpnNodes "nwvpn"))
        );
      }

      (nwJob "apu2" "apu2" "node" true)
      (nwJob "htz1" "htz1" "node" true)
      (nwJob "htz2" "htz2" "node" true)
      (nwJob "htz2" "htz2" "maddy" true)
      (nwJob "htz3" "htz3" "node" true)
      (nwJob "nas1" "nas1" "node" true)
      (nwJob "rpi2" "rpi2" "node" true)
      (nwJob "ws1" "ws1" "node" false)

      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_2xx";
        params.module = [ "http_2xx" ];
        static_configs = [
          {
            targets = [
              "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.octoprint}"
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
              "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.grafana}/login"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_home_assistant_bs53";
        params.module = [ "http_home_assistant_bs53" ];
        static_configs = [
          {
            targets = [
              "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.home-assistant}"
            ];
          }
        ];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_home_assistant_dlrg";
        params.module = [ "http_home_assistant_dlrg" ];
        static_configs = [
          {
            targets = [
              "http://apu2.nw:8123"
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
              "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.nginx-monica}"
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
    ];
  };
}
