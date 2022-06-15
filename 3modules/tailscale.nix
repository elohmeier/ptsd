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
      description = "HTTP services exposed via haproxy on Tailscale network";
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

      services.haproxy = mkIf cfg.cert.enable {
        enable = true;
        config = ''
          defaults
            timeout connect 10s


          ${concatMapStrings (svc: ''

          backend ${svc}
            mode http
            server s1 127.0.0.1:${toString config.ptsd.ports."${svc}"}

          '') (cfg.httpServices ++ ["nginx-tsindex"])}


          ${concatMapStrings (svc: ''

          frontend ${svc}
            bind ${cfg.ip}:${toString config.ptsd.ports."${svc}"} interface ${config.services.tailscale.interfaceName} ssl crt /var/lib/tailscale-cert/${cfg.fqdn}.pem
            mode http
            use_backend ${svc}

          '') cfg.httpServices}

          frontend https
            bind ${cfg.ip}:443 interface ${config.services.tailscale.interfaceName} ssl crt /var/lib/tailscale-cert/${cfg.fqdn}.pem
            mode http
            use_backend nginx-tsindex
        '';
      };

      systemd.services.haproxy.serviceConfig.SupplementaryGroups = "tailscale-cert";

      systemd.services.haproxy.after = [ "tailscaled.service" ];
      systemd.services.haproxy.wants = [ "tailscaled.service" ];

      services.nginx = {
        enable = true;

        virtualHosts."${cfg.fqdn}" = {
          listen = [{ addr = "127.0.0.1"; port = config.ptsd.ports.nginx-tsindex; }];
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
      };
    })
  ];
}
