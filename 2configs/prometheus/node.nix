{ config, lib, pkgs, ... }:
let
  port = 9100;
in
{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = config.ptsd.nwtraefik.ports.prometheus-node;
    enabledCollectors = import ./node_collectors.nix;
  };

  ptsd.nwtraefik = {
    enable = true;
    entryPoints = {
      nwvpn-prometheus = {
        address = "${config.ptsd.wireguard.networks.nwvpn.ip}:${toString port}";
      };
    };
    middlewares = {
      prom-stripprefix = {
        stripprefixregex = {
          regex = "/[a-zA-Z0-9]+/[a-zA-Z0-9]+/";
        };
      };
    };
    services = [
      {
        name = "prometheus-node";
        entryPoints = [ "nwvpn-prometheus" ];
        rule = "PathPrefix(`/${config.networking.hostName}/node`) && Host(`${config.ptsd.wireguard.networks.nwvpn.ip}`)";
        tls = false;
        extraMiddlewares = [ "prom-stripprefix" ];
      }
    ];
  };

  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ port ];
}
