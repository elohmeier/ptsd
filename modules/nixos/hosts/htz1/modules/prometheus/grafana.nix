{ config, ... }:
let
  port = config.ptsd.ports.grafana;
in
{
  services.grafana =
    {
      enable = true;
      settings = {
        security = {
          admin_password = "$__file{/run/credentials/grafana.service/grafana.adminPassword}";
          admin_user = "enno";
          secret_key = "$__file{/run/credentials/grafana.service/grafana.secretKey}";
        };
        server = {
          http_addr = "127.0.0.1";
          http_port = port;
          root_url = "https://${config.ptsd.tailscale.fqdn}:${toString port}/";
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            isDefault = true;
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString config.ptsd.ports.prometheus-server}";
            jsonData.timeInterval = "60s";
          }
          {
            name = "Prometheus k3s convexio";
            type = "prometheus";
            url = "http://100.65.148.97:9090";
            jsonData.timeInterval = "15s";
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://100.106.245.41:${toString config.ptsd.ports.loki}";
          }
          {
            name = "Loki k3s convexio";
            type = "loki";
            url = "http://100.65.148.97:3100";
          }
        ];
      };
    };

  systemd.services.grafana.serviceConfig.LoadCredential = [
    "grafana.adminPassword:/var/src/secrets/prometheus/grafana.adminPassword"
    "grafana.secretKey:/var/src/secrets/prometheus/grafana.secretKey"
  ];
}
