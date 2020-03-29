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
        ];
      };
    };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "grafana";
      rule = "Host:${domain}";
    }
  ];

  # TODO: test config
  ptsd.nwmonit.extraConfig = [
    ''
      check host ${domain} with address ${domain}
        if failed
          port 80
          protocol http
          status = 302
        then alert

        if failed
          port 443
          certificate valid > 30 days
          protocol https
          content = "Grafana"
        then alert
    ''
  ];
}
