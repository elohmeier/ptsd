{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.tailscale;
  fqdn = "${config.networking.hostName}.${cfg.domain}";
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
    cert.enable = mkEnableOption "fetch TLS certificate";
  };

  config = mkIf cfg.enable {

    users.groups.tailscale-cert = mkIf cfg.cert.enable { };
    users.users.tailscale-cert = mkIf cfg.cert.enable {
      group = "tailscale-cert";
      isSystemUser = true;
    };

    services.tailscale = {
      enable = true;
      #permitCertUid = "tailscale-cert"; # TODO: replace below env var in 22.05 with permitCertUid
    };
    systemd.services.tailscaled.serviceConfig.Environment = mkIf cfg.cert.enable [ "TS_PERMIT_CERT_UID=tailscale-cert" ];

    systemd.services.tailscale-cert = mkIf cfg.cert.enable {
      description = "fetch tailscale host TLS certificate";
      script = ''
        ${config.services.tailscale.package}/bin/tailscale cert "${fqdn}"
        cat "${fqdn}.crt" "${fqdn}.key" > "${fqdn}.pem"
        chmod 640 "${fqdn}.key"
        chmod 640 "${fqdn}.pem"
      '';
      serviceConfig = {
        StateDirectory = "tailscale-cert";
        WorkingDirectory = "/var/lib/tailscale-cert";
        User = "tailscale-cert";
        Group = "tailscale-cert";
      };
      startAt = "daily";
    };

    # systemd.sockets.tailscale-http = {
    #   wantedBy = [ "sockets.target" ];
    #   socketConfig = {
    #     ListenStream = ":80";
    #     BindToDevice = config.services.tailscale.interfaceName;
    #   };
    # };

    # TODO: generate config & add index html page
    services.haproxy = mkIf cfg.cert.enable {
      enable = true;
      config = ''
        defaults
          timeout connect 10s

        backend octoprint
          mode http
          server s1 127.0.0.1:${toString config.ptsd.ports.octoprint}
  
        backend mjpg
          mode http
          server s1 127.0.0.1:${toString config.ptsd.ports.mjpg-streamer}

        frontend octoprint
          bind ${cfg.ip}:${toString config.ptsd.ports.octoprint} interface ${config.services.tailscale.interfaceName} ssl crt /var/lib/tailscale-cert/${fqdn}.pem
          mode http
          use_backend octoprint

        frontend mjpg
          bind ${cfg.ip}:${toString config.ptsd.ports.mjpg-streamer} interface ${config.services.tailscale.interfaceName} ssl crt /var/lib/tailscale-cert/${fqdn}.pem
          mode http
          use_backend mjpg
      '';
    };

    systemd.services.haproxy.serviceConfig.SupplementaryGroups = "tailscale-cert";

    networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  };
}
