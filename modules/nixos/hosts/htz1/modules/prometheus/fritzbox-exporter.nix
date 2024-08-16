{ pkgs, ... }:
{

  systemd.services.prometheus-fritzbox-exporter = {
    description = "Prometheus exporter for Fritz!Box home routers";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.fritzbox-exporter}/bin/fritz_exporter.py";
      Restart = "always";
      PrivateTmp = true;
      WorkingDirectory = "/tmp";
      DynamicUser = true;
      EnvironmentFile = "/var/src/secrets/prometheus/prometheus-fritzbox-exporter.env";
    };
    environment = {
      FRITZ_EXPORTER_PORT = "9787";
    };
  };

}
