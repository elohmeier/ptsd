{ config, lib, pkgs, ... }: {


  systemd.services.prometheus-quotes-exporter = {
    description = "Prometheus exporter for quotes";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.quotes-exporter}/bin/quotes-exporter -port ${toString config.ptsd.ports.prometheus-quotes-exporter}";
      Restart = "always";
      DynamicUser = true;
    };
  };

}
