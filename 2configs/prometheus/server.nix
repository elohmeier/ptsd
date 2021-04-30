{ config, lib, pkgs, ... }:

with lib;
let
  universe = import ../universe.nix;
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

  nwJob = host: unit: exporter: {
    job_name = "${exporter}_${host}_${unit}";
    scrape_interval = "60s";
    metrics_path = "/${unit}/${exporter}/metrics";
    static_configs = [{
      targets = [
        "${universe.hosts."${host}".nets.nwvpn.ip4.addr}:9100"
      ];
      labels = {
        alias = if host == unit then host else "${host}-${unit}";
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
    port = config.ptsd.nwtraefik.ports.prometheus;
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
                };
              }
            )
            (vpnNodes "nwvpn")
        );
      }

      (nwJob "htz3" "htz3" "node")
      (nwJob "htz3" "gitlab" "node")
      (nwJob "htz3" "wpjail" "node")

      (nwJob "ws1" "ws1" "node")
      (nwJob "ws2" "ws2" "node")
      (nwJob "tp1" "tp1" "node")

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

    exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      configFile = pkgs.writeText "blackbox.json" (builtins.toJSON {
        modules = {
          http_2xx = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
            };
          };

          http_acme_dns = {
            prober = "http";
            timeout = "2s";
            http = {
              valid_status_codes = [ 405 ];
              fail_if_not_ssl = true;
            };
          };

          http_fraam_www = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Ihr Projekterfolg."
              ];
            };
          };

          http_nextcloud = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "a safe home for all your data"
              ];
            };
          };

          http_gitea = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Gitea - Git with a cup of tea"
              ];
            };
          };

          http_nerdworks_www = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Nerdworks Hamburg unterstützt Unternehmen bei."
              ];
            };
          };


          http_grafana = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Grafana"
              ];
            };
          };

          http_home_assistant = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Home Assistant"
              ];
            };
          };

          http_monica = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Monica – personal relationship manager"
              ];
            };
          };

          # http_drone = {
          #   prober = "http";
          #   timeout = "2s";
          #   http = {
          #     fail_if_not_ssl = true;
          #     fail_if_body_not_matches_regexp = [
          #       "Drone"
          #     ];
          #   };
          # };

          http_gitlab = {
            prober = "http";
            timeout = "2s";
            http = {
              method = "HEAD";
              fail_if_not_ssl = true;
              valid_status_codes = [ 302 ];
              no_follow_redirects = true;
              fail_if_header_not_matches = [
                {
                  header = "Location";
                  regexp = "https://.+/users/sign_in";
                }
              ];
            };
          };
        };
      });
    };

    alertmanagers = [
      {
        scheme = "http";
        path_prefix = "/";
        static_configs = [{ targets = [ "127.0.0.1:${toString config.ptsd.nwtraefik.ports.alertmanager}" ]; }];
      }
    ];

    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = config.ptsd.nwtraefik.ports.alertmanager;
      webExternalUrl = "https://nas1.host.nerdworks.de/";
      configuration = {
        route = {
          group_by = [ "alertname" "alias" ];
          receiver = "nwadmins";
        };
        receivers = [{
          name = "nwadmins";
          webhook_configs = [{
            url = "http://127.0.0.1:16320";
            send_resolved = true;
          }];
        }];
      };
    };

    rules = [
      (builtins.toJSON {
        groups = [{
          name = "nwenv";
          rules = [
            {
              alert = "DiskSpace10%Free";
              expr = ''node_filesystem_avail_bytes{mountpoint!~"/mnt/backup/.*|/boot"}/node_filesystem_size_bytes * 100 < 10'';
              for = "30m";
              labels.severity = "warning";
              annotations = {
                summary = "{{ $labels.alias }} disk {{ $labels.mountpoint }} full";
                url = "https://grafana.services.nerdworks.de/d/hb7fSE0Zz/1-node-exporter-for-prometheus-dashboard-en-v20191102?orgId=1&var-hostname={{ $labels.alias }}";
                description = ''The disk {{ $labels.mountpoint }} of host {{ $labels.alias }} has {{ $value | printf "%.1f" }}% free disk space remaining.'';
              };
            }
            {
              alert = "DiskInodes10%Free";
              expr = ''node_filesystem_files_free/node_filesystem_files * 100 < 10'';
              for = "30m";
              labels.severity = "warning";
              annotations = {
                summary = "{{ $labels.alias }} disk {{ $labels.mountpoint }} inodes exhausted";
                url = "https://grafana.services.nerdworks.de/d/hb7fSE0Zz/1-node-exporter-for-prometheus-dashboard-en-v20191102?orgId=1&var-hostname={{ $labels.alias }}";
                description = ''The disk {{ $labels.mountpoint }} of host {{ $labels.alias }} has {{ $value | printf "%.1f" }}% free inodes remaining.'';
              };
            }
            {
              alert = "EndpointDown";
              expr = "probe_success == 0";
              for = "30s";
              labels.severity = "critical";
              annotations = {
                summary = "Endpoint {{ $labels.instance }} down";
              };
            }
            {
              alert = "SystemdUnitFailed";
              expr = ''node_systemd_unit_state{state="failed"}==1'';
              for = "30m";
              labels.severity = "warning";
              annotations = {
                summary = "Unit {{ $labels.name }}@{{ $labels.alias }} failed";
                url = "https://grafana.services.nerdworks.de/d/YMUqHaqWz/prometheus-service-monitoring";
                description = "Unit entered failed state";
              };
            }
            {
              alert = "TLSCertExpiringSoon";
              expr = "probe_ssl_earliest_cert_expiry - time() < 86400 * 28";
              for = "10m";
              labels.severity = "warning";
              annotations = {
                summary = "Certificate for {{ $labels.instance }} expiring soon";
                description = "Certificate is about to expire in less than 28 days.";
              };
            }
          ];
        }];
      })
    ];
  };

  ptsd.secrets.files."prometheus-fritzbox-exporter.env" = {
    dependants = [ "prometheus-fritzbox-exporter.service" ];
  };

  systemd.services.prometheus-fritzbox-exporter = {
    description = "Prometheus exporter for Fritz!Box home routers";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.fritzbox-exporter}/bin/fritz_exporter.py";
      Restart = "always";
      PrivateTmp = true;
      WorkingDirectory = "/tmp";
      DynamicUser = true;
      EnvironmentFile = config.ptsd.secrets.files."prometheus-fritzbox-exporter.env".path;
    };
    environment = {
      # managed via EnvironmentFile
      #FRITZ_EXPORTER_CONFIG = "192.168.178.1,prometheus,${prometheusSecrets.fritzPassword}";
      FRITZ_EXPORTER_PORT = "9787";
    };
  };

  ptsd.nwtraefik = {
    services = [
      {
        name = "alertmanager";
        entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
        rule = "Host(`alerts.services.nerdworks.de`)";
      }
      {
        name = "prometheus";
        entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
        rule = "Host(`prometheus.services.nerdworks.de`)";
      }
    ];
  };

  ptsd.alertmanager-bot = {
    enable = true;
    listenAddress = "127.0.0.1:16320";
    templatePath = ./telegram.tmpl;
    envFile = config.ptsd.secrets.files."alertmanager-bot.env".path;
  };

  ptsd.secrets.files."alertmanager-bot.env" = {
    dependants = [ "alertmanager-bot.service" ];
  };
}
