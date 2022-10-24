{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.tailscale;
  allLinks = cfg.httpServices ++ cfg.links;
  universe = import ../2configs/universe.nix;
in
{
  options.ptsd.tailscale = {
    enable = mkEnableOption "tailscale";
    ip = mkOption {
      type = types.str;
      default = universe.hosts."${config.networking.hostName}".nets.tailscale.ip4.addr;
    };
    domain = mkOption {
      type = types.str;
      default = "pug-coho.ts.net";
    };
    fqdn = mkOption {
      type = types.str;
      default = "${config.networking.hostName}.${cfg.domain}";
    };
    cert.enable = mkEnableOption "fetch TLS certificate";
    httpServices = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "HTTP services exposed via reverse proxy on Tailscale network";
    };
    links = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "HTTP services directly exposed, linked on the index page";
    };
  };

  config = mkMerge [

    (mkIf cfg.enable {
      services.tailscale.enable = true;

      services.fail2ban.ignoreIP = [ "100.64.0.0/10" ];

      networking.firewall = {
        checkReversePath = "loose";
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
      };
    })

    (mkIf (cfg.enable && cfg.cert.enable) {
      users.groups.tailscale-cert = mkIf cfg.cert.enable { };
      users.users.tailscale-cert = mkIf cfg.cert.enable {
        group = "tailscale-cert";
        isSystemUser = true;
      };

      services.tailscale.permitCertUid = "tailscale-cert";

      systemd.services.tailscale-cert = mkIf cfg.cert.enable {
        description = "fetch tailscale host TLS certificate";
        script = ''
          ${config.services.tailscale.package}/bin/tailscale cert "${cfg.fqdn}"
          cat "${cfg.fqdn}.crt" "${cfg.fqdn}.key" > "${cfg.fqdn}.pem"
          chmod 640 "${cfg.fqdn}.key"
          chmod 640 "${cfg.fqdn}.pem"
        '';
        serviceConfig = {
          StateDirectory = "tailscale-cert";
          WorkingDirectory = "/var/lib/tailscale-cert";
          User = "tailscale-cert";
          Group = "tailscale-cert";
        };
        startAt = "daily";
      };
    })

    (mkIf (cfg.enable && cfg.cert.enable && allLinks != [ ]) {

      systemd.services.nginx = {
        requires = [ "tailscale-cert.service" ];
        after = [ "tailscale-cert.service" ];
        serviceConfig.SupplementaryGroups = "tailscale-cert";
      };

      services.nginx = {
        enable = true;

        virtualHosts = {
          "${cfg.fqdn}" = {
            listenAddresses = [ cfg.ip ];
            addSSL = true;
            sslCertificate = "/var/lib/tailscale-cert/${cfg.fqdn}.crt";
            sslCertificateKey = "/var/lib/tailscale-cert/${cfg.fqdn}.key";
            root = pkgs.writeTextFile {
              name = "tsindex";
              destination = "/index.html";
              text = ''
                <!DOCTYPE html>
                <html lang="en">
                  <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <meta http-equiv="X-UA-Compatible" content="ie=edge">
                    <title>${cfg.fqdn}</title>
                  </head>
                  <body>
                    <h2>${cfg.fqdn}</h2>
                    <ul>
                ${concatMapStrings (svc: ''
                      <li><a href="https://${cfg.fqdn}:${toString config.ptsd.ports."${svc}"}">${svc}</a></li>
                '') allLinks}
                    </ul>
                  </body>
                </html>
              '';
            };
          };
        } // (builtins.listToAttrs (map
          (name: {
            inherit name; value = {
            forceSSL = true;
            listen = [{ addr = cfg.ip; port = config.ptsd.ports."${name}"; ssl = true; }];
            sslCertificate = "/var/lib/tailscale-cert/${cfg.fqdn}.crt";
            sslCertificateKey = "/var/lib/tailscale-cert/${cfg.fqdn}.key";

            locations."/".extraConfig = ''
              proxy_http_version 1.1;
              proxy_pass http://127.0.0.1:${toString config.ptsd.ports."${name}"};
              proxy_set_header Connection $http_connection;
              proxy_set_header Host $host;
              proxy_set_header Upgrade $http_upgrade;
            '';
          };
          })
          cfg.httpServices));
      };
    })
  ];
}
