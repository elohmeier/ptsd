{ config, lib, pkgs, ... }: {



  ptsd.secrets.files."prometheus-fritzbox-exporter.env" = {
    dependants = [ "prometheus-fritzbox-exporter.service" ];
    source-path = "/var/src/secrets/prometheus/prometheus-fritzbox-exporter.env";
  };

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
      EnvironmentFile = config.ptsd.secrets.files."prometheus-fritzbox-exporter.env".path;
    };
    environment = {
      # managed via EnvironmentFile
      #FRITZ_EXPORTER_CONFIG = "192.168.178.1,prometheus,${prometheusSecrets.fritzPassword}";
      FRITZ_EXPORTER_PORT = "9787";
    };
  };

}
