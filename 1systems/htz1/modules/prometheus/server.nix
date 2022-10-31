{ config, lib, pkgs, ... }:

with lib;
let
  universe = import ../../../../2configs/universe.nix;
  blackboxGenericScrapeConfig = {
    scrape_interval = "60s";
    metrics_path = "/probe";
    relabel_configs = [
      { source_labels = [ "__address__" ]; target_label = "__param_target"; }
      { source_labels = [ "__param_target" ]; target_label = "instance"; }
      { target_label = "__address__"; replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}"; }
    ];
  };
in
{
  systemd.services.prometheus.serviceConfig.LoadCredential = [
    "hass-token-home:/var/src/secrets/prometheus/hass-token-home"
    "hass-token-dlrg:/var/src/secrets/prometheus/hass-token-dlrg"
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
        job_name = "pushgateway";
        scrape_interval = "60s";
        scheme = "https";
        static_configs = [{ targets = [ "htz1.pug-coho.ts.net:${toString config.ptsd.ports.prometheus-pushgateway}" ]; }];
      }
      {
        job_name = "hass_home";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        bearer_token_file = "/run/credentials/prometheus.service/hass-token-home";
        scheme = "https";
        static_configs = [{ targets = [ "htz1.pug-coho.ts.net:${toString config.ptsd.ports.home-assistant}" ]; }];
      }
      {
        job_name = "hass_dlrg";
        scrape_interval = "60s";
        metrics_path = "/api/prometheus";
        bearer_token_file = "/run/credentials/prometheus.service/hass-token-dlrg";
        scheme = "https";
        static_configs = [{ targets = [ "rotebox.nn42.de" ]; }];
      }
      {
        job_name = "fritzbox";
        scrape_interval = "60s";
        static_configs = [{ targets = [ "127.0.0.1:9787" ]; }];
      }
      {
        job_name = "quotes";
        scrape_interval = "60s";
        metrics_path = "/price";
        params.symbols = lib.importJSON ./securities.json;
        static_configs = [{ targets = [ "127.0.0.1:${toString config.ptsd.ports.prometheus-quotes-exporter}" ]; }];
      }

      {
        job_name = "node_wrt";
        scrape_interval = "60s";
        static_configs = [
          # { targets = [ "${universe.hosts.wrt1.nets.nwvpn.ip4.addr}:9100" ]; labels = { alias = "wrt1"; alwayson = "1"; }; }
          { targets = [ "${universe.hosts.wrt2.nets.nwvpn.ip4.addr}:9100" ]; labels = { alias = "wrt2"; alwayson = "1"; }; }
        ];
      }

      {
        job_name = "node_ts";
        scrape_interval = "60s";
        static_configs = map
          (host: {
            targets = [ "${universe.hosts."${host}".nets.tailscale.ip4.addr}:9100" ];
            labels = {
              alias = host;
              alwayson = "1";
            };
          }) [
          "htz1"
          "htz2"
          "htz3"
          "rpi4"
          "rotebox"
          "matrix"
        ];
      }

      {
        job_name = "maddy";
        scrape_interval = "60s";
        static_configs = [{ targets = [ "htz2.pug-coho.ts.net:${toString config.ptsd.ports.prometheus-maddy}" ]; labels.alias = "htz2"; }];
      }

      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_2xx";
        params.module = [ "http_2xx" ];
        static_configs = [{
          targets = [
            # "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.octoprint}"
            "https://vault.fraam.de"
          ];
        }];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_fraam_www";
        params.module = [ "http_fraam_www" ];
        static_configs = [{ targets = [ "https://www.fraam.de" ]; }];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_nerdworks_www";
        params.module = [ "http_nerdworks_www" ];
        static_configs = [{ targets = [ "https://www.nerdworks.de" ]; }];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_grafana";
        params.module = [ "http_grafana" ];
        static_configs = [{ targets = [ "https://htz1.pug-coho.ts.net:${toString config.ptsd.ports.grafana}/login" ]; }];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_home_assistant_home";
        params.module = [ "http_home_assistant" ];
        static_configs = [{ targets = [ "https://htz1.pug-coho.ts.net:${toString config.ptsd.ports.home-assistant}" ]; }];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_home_assistant_dlrg";
        params.module = [ "http_home_assistant" ];
        static_configs = [{ targets = [ "https://rotebox.nn42.de" ]; }];
      })
      (blackboxGenericScrapeConfig // {
        job_name = "blackbox_http_monica";
        params.module = [ "http_monica" ];
        static_configs = [{ targets = [ "https://htz1.pug-coho.ts.net:${toString config.ptsd.ports.monica}" ]; }];
      })

      {
        job_name = "blackbox_rotebox_fritzbox";
        metrics_path = "/probe";
        params.module = [ "http_2xx_fritzbox" ];
        relabel_configs = [
          { source_labels = [ "__address__" ]; target_label = "__param_target"; }
          { source_labels = [ "__param_target" ]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "rotebox.pug-coho.ts.net:9115"; }
        ];
        scrape_interval = "60s";
        static_configs = [{ targets = [ "http://191.18.22.2" "http://191.18.22.4" ]; }];
      }

      {
        job_name = "blackbox_rotebox_homematic";
        metrics_path = "/probe";
        params.module = [ "http_2xx_homematic" ];
        relabel_configs = [
          { source_labels = [ "__address__" ]; target_label = "__param_target"; }
          { source_labels = [ "__param_target" ]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "rotebox.pug-coho.ts.net:9115"; }
        ];
        scrape_interval = "60s";
        static_configs = [{ targets = [ "http://191.18.22.3" ]; }];
      }
    ];
  };
}
