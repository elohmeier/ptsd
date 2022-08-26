{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.tailscale;
in
{
  options.ptsd.tailscale = {
    enable = mkEnableOption "tailscale";
    ip = mkOption {
      type = types.str;
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
  };

  config = mkMerge [

    (mkIf cfg.enable {
      services.tailscale.enable = true;

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

    (mkIf (cfg.enable && cfg.cert.enable && cfg.httpServices != [ ]) {

      systemd.services.nginx.serviceConfig.SupplementaryGroups = "tailscale-cert";

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
                '') cfg.httpServices}
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
              proxy_pass http://127.0.0.1:${toString config.ptsd.ports."${name}"};
            '';
          };
          })
          cfg.httpServices));
      };
    })
  ];
}
