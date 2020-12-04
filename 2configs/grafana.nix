{ config, lib, pkgs, ... }:
let
  domain = "grafana.services.nerdworks.de";
  grafanaSecrets = import <secrets/grafana.nix>;
in
{

  services.grafana =
    {
      enable = true;
      port = config.ptsd.nwtraefik.ports.grafana;
      rootUrl = "https://${domain}/";
      security = {
        adminUser = grafanaSecrets.adminUser;
        adminPassword = grafanaSecrets.adminPassword;
      };
      provision = {
        enable = true;
        datasources = [
          {
            name = "InfluxDB Telegraf";
            type = "influxdb";
            isDefault = true;
            database = "telegraf";
            user = "grafana";
            password = grafanaSecrets.influxPassword;
            url = "https://influxdb.services.nerdworks.de";
          }
          {
            name = "InfluxDB Home Assistant";
            type = "influxdb";
            isDefault = false;
            database = "hass";
            user = "grafana";
            password = grafanaSecrets.influxPassword;
            url = "https://influxdb.services.nerdworks.de";
          }
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
          }
        ];
      };
    };

  ptsd.nwtraefik.services = [
    {
      name = "grafana";
      rule = "Host(`${domain}`)";
    }
  ];
}
