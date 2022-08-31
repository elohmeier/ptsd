{ config, lib, pkgs, ... }:

{
  services.prometheus.pushgateway = {
    enable = true;
    persistMetrics = true;
    web.listen-address = "127.0.0.1:${toString config.ptsd.ports.prometheus-pushgateway}";
  };
}
