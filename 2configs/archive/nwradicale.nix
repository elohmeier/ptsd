{ config, lib, pkgs, ... }:
let
  domain = "mail.nerdworks.de";
  monitoringSecrets = import <secrets/monitoring.nix>;
in
{
  ptsd.secrets.files."radicale.htpasswd" = {
    path = "/run/radicale/radicale.htpasswd";
    dependants = [ "radicale.service" ];
  };

  systemd.services.radicale.partOf = [ "secret-radicale.htpasswd.service" ];

  ptsd.radicale = {
    enable = true;
    port = config.ptsd.nwtraefik.ports.radicale;
    htpasswd = config.ptsd.secrets.files."radicale.htpasswd".path;
  };

  ptsd.nwtraefik.services = [
    {
      name = "radicale";
      rule = "Host(`${domain}`)";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" ];
      }
      {
        urls = [ "https://${domain}/.web" ];
        headers =
          let
            basicAuthEncoded = builtins.readFile (
              pkgs.runCommand "b64auth"
                {
                  preferLocalBuild = true;
                } ''
                echo "${monitoringSecrets.radicaleUsername}:${monitoringSecrets.radicalePassword}" \
                base64 > $out
              ''
            );
          in
          {
            Authorization = "Basic ${basicAuthEncoded}";
          };
      }
    ];
    x509_cert = [
      {
        sources = [
          "https://${domain}:443"
        ];
      }
    ];
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check process radicale matching "\.radicale-wrapped"
        start program = "${pkgs.systemd}/bin/systemctl start radicale"
        stop program = "${pkgs.systemd}/bin/systemctl stop radicale"

        if failed
          host ${domain}
          port 443
          certificate valid > 30 days
          protocol https
          username "${monitoringSecrets.radicaleUsername}"
          password "${monitoringSecrets.radicalePassword}"
          request "/.web"
          then alert
    ''
  ];
}
