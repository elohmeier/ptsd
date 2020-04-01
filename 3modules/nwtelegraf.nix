{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwtelegraf;
  configOptions =
    {
      outputs = {
        influxdb = {
          urls = [ "https://influxdb.services.nerdworks.de" ];
          database = "telegraf";
          skip_database_creation = true;
          username = "telegraf";
          password = cfg.influxPassword;
        };
      };
      inputs = {
        # Host metrics as in https://grafana.com/grafana/dashboards/928
        cpu = {
          percpu = true;
          totalcpu = true;
          fielddrop = [ "time_*" ];
        };
        disk = {
          ignore_fs = [ "tmpfs" "devtmpfs" ];
        };
        diskio = {};
        interrupts = {};
        kernel = {};
        linux_sysctl_fs = {};
        mem = {};
        net = {};
        netstat = {};
        processes = {};
        swap = {};
        system = {};
        temp = {};
        x509_cert = [
          {
            sources = [
              "https://${config.networking.hostName}.${config.networking.domain}:443"
            ];
          }
        ];
      } // lib.optionalAttrs (cfg.inputs.file != []) { file = cfg.inputs.file; }
      // lib.optionalAttrs (cfg.inputs.http != []) { http = cfg.inputs.http; }
      // lib.optionalAttrs (cfg.inputs.influxdb != []) { influxdb = cfg.inputs.influxdb; };
    };
in
{

  options = {
    ptsd.nwtelegraf = {
      enable = mkEnableOption "nwtelegraf";
      influxPassword = mkOption { type = types.str; };
      inputs = mkOption {
        type = types.submodule {
          options = {
            # extend as needed
            file = mkOption { type = types.listOf types.attrs; };
            http = mkOption { type = types.listOf types.attrs; };
            influxdb = mkOption { type = types.listOf types.attrs; };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {

    services.telegraf = {
      enable = true;
      extraConfig = configOptions;
    };

    systemd.services.telegraf.serviceConfig.TimeoutStopSec = "10s";
  };
}
