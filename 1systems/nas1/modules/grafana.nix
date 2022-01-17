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

  users.groups.keys.members = [ "grafana" ];

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
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString config.ptsd.nwtraefik.ports.prometheus}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:${toString config.ptsd.nwtraefik.ports.loki}";
          }
        ];
      };
    };

  ptsd.nwtraefik.services = [
    {
      name = "grafana";
      rule = "Host(`${domain}`)";
      entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
    }
  ];
}
