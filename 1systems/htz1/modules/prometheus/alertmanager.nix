{ config, lib, pkgs, ... }:

{
  services.prometheus = {
    alertmanagers = [
      {
        scheme = "http";
        path_prefix = "/";
        static_configs = [{ targets = [ "127.0.0.1:${toString config.ptsd.ports.alertmanager}" ]; }];
      }
    ];

    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = config.ptsd.ports.alertmanager;
      webExternalUrl = "https://${config.ptsd.tailscale.fqdn}:${toString config.ptsd.ports.alertmanager}/";
      configuration = {
        route = {
          group_by = [ "alertname" "alias" ];
          receiver = "nwadmins";
        };
        receivers = [{
          name = "nwadmins";
          webhook_configs = [{
            url = "http://matrix.pug-coho.ts.net:4050/services/hooks/YWxlcnRtYW5hZ2VyX3NlcnZpY2U";
            send_resolved = true;
          }];
        }];
      };
    };

    rules = [
      (builtins.toJSON {
        groups = [{
          name = "nwenv";
          rules = [
            {
              alert = "DiskSpace10%Free";
              expr = ''node_filesystem_avail_bytes{mountpoint!~"/mnt/backup/.*|/boot"}/node_filesystem_size_bytes * 100 < 10'';
              for = "30m";
              labels.severity = "warning";
              annotations = {
                summary = "{{ $labels.alias }} disk {{ $labels.mountpoint }} full";
                url = "https://grafana.services.nerdworks.de/d/hb7fSE0Zz/1-node-exporter-for-prometheus-dashboard-en-v20191102?orgId=1&var-hostname={{ $labels.alias }}";
                description = ''The disk {{ $labels.mountpoint }} of host {{ $labels.alias }} has {{ $value | printf "%.1f" }}% free disk space remaining.'';
              };
            }
            {
              alert = "DiskInodes10%Free";
              expr = ''node_filesystem_files_free/node_filesystem_files * 100 < 10'';
              for = "30m";
              labels.severity = "warning";
              annotations = {
                summary = "{{ $labels.alias }} disk {{ $labels.mountpoint }} inodes exhausted";
                url = "https://grafana.services.nerdworks.de/d/hb7fSE0Zz/1-node-exporter-for-prometheus-dashboard-en-v20191102?orgId=1&var-hostname={{ $labels.alias }}";
                description = ''The disk {{ $labels.mountpoint }} of host {{ $labels.alias }} has {{ $value | printf "%.1f" }}% free inodes remaining.'';
              };
            }
            {
              alert = "EndpointDown";
              expr = "probe_success == 0";
              for = "30s";
              labels.severity = "critical";
              annotations = {
                summary = "Endpunkt {{ $labels.instance }} ist nicht erreichbar";
              };
            }
            {
              alert = "SystemdUnitFailed";
              expr = ''node_systemd_unit_state{state="failed",name!="wpa_supplicant.service"}==1'';
              for = "30m";
              labels.severity = "warning";
              annotations = {
                summary = "Unit {{ $labels.name }}@{{ $labels.alias }} failed";
                url = "https://grafana.services.nerdworks.de/d/YMUqHaqWz/prometheus-service-monitoring";
                description = "Unit entered failed state";
              };
            }
            {
              alert = "TLSCertExpiringSoon";
              expr = "probe_ssl_earliest_cert_expiry - time() < 86400 * 28";
              for = "10m";
              labels.severity = "warning";
              annotations = {
                summary = "Certificate for {{ $labels.instance }} expiring soon";
                description = "Certificate is about to expire in less than 28 days.";
              };
            }
            {
              alert = "CheckSSLCertFailed";
              expr = "check_ssl_cert_result > 0";
              labels.severity = "critical";
              annotations = {
                summary = "Certificate check failed";
                description = "Certificate check for {{ $labels.protocol }}://{{ $labels.host }}:{{ $labels.port }} failed with exit code {{ $value }}.";
              };
            }
            {
              alert = "NodeDown";
              expr = ''up{alwayson="1"} == 0'';
              for = "5m";
              labels.severity = "critical";
              annotations = {
                summary = "Node {{ $labels.alias }} down";
                description = "{{ $labels.alias }} ist seit mehr als fünf Minuten nicht erreichbar.";
              };
            }
            {
              alert = "OldBackup";
              expr = "time() - backup_completion_time > 86400 * 14";
              for = "10m";
              labels.severity = "warning";
              annotations = {
                summary = "No recent backup for {{ $labels.alias }}";
                description = "The last backup is older than 14 days.";
              };
            }
          ];
        }];
      })
    ];
  };
}
