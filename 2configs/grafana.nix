{ config, lib, pkgs, ... }:
let
  domain = "grafana.services.nerdworks.de";
in
{
  ptsd.secrets.files."grafana.adminPassword" = {
    dependants = [ "grafana.service" ];
    owner = "grafana";
  };
  ptsd.secrets.files."grafana.secretKey" = {
    dependants = [ "grafana.service" ];
    owner = "grafana";
  };

  services.grafana =
    {
      enable = true;
      port = config.ptsd.nwtraefik.ports.grafana;
      rootUrl = "https://${domain}/";
      security = {
        adminUser = "enno";
        adminPasswordFile = config.ptsd.secrets.files."grafana.adminPassword".path;
        secretKeyFile = config.ptsd.secrets.files."grafana.secretKey".path;
      };
      provision = {
        enable = true;
        datasources = [
          # {
          #   name = "InfluxDB Telegraf";
          #   type = "influxdb";
          #   isDefault = true;
          #   database = "telegraf";
          #   user = "grafana";
          #   password = grafanaSecrets.influxPassword;
          #   url = "https://influxdb.services.nerdworks.de";
          # }
          # {
          #   name = "InfluxDB Home Assistant";
          #   type = "influxdb";
          #   isDefault = false;
          #   database = "hass";
          #   user = "grafana";
          #   password = grafanaSecrets.influxPassword;
          #   url = "https://influxdb.services.nerdworks.de";
          # }
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
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
