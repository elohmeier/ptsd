{ config, lib, pkgs, ... }:
let
  port = config.ptsd.ports.grafana;
in
{
  services.grafana =
    {
      inherit port;
      enable = true;
      rootUrl = "https://${config.ptsd.tailscale.fqdn}:${toString port}/";
      security = {
        adminUser = "enno";
        adminPasswordFile = "/run/credentials/grafana.service/grafana.adminPassword";
        secretKeyFile = "/run/credentials/grafana.service/grafana.secretKey";
      };
      provision = {
        enable = true;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString config.ptsd.ports.prometheus-server}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:${toString config.ptsd.ports.loki}";
          }
        ];
      };
    };

  systemd.services.grafana.serviceConfig.LoadCredential = [
    "grafana.adminPassword:/var/src/secrets/grafana.adminPassword"
    "grafana.secretKey:/var/src/secrets/grafana.secretKey"
  ];
}
