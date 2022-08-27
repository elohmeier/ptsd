{ config, lib, pkgs, ... }:

{
  services.prometheus.pushgateway = {
    enable = true;
    persistMetrics = true;
    web.listen-address = "${config.ptsd.tailscale.ip}:${toString config.ptsd.ports.prometheus-pushgateway}";
  };
}
