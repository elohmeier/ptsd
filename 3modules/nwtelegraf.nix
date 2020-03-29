{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwtelegraf;
  configOptions = recursiveUpdate {
    outputs = {
      influxdb = {
        urls = [ "https://influxdb.services.nerdworks.de" ];
        database = "telegraf";
        skip_database_creation = true;
        username = "telegraf";
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
    };
  } cfg.extraConfig;
in
{

  options = {
    ptsd.nwtelegraf = {
      enable = mkEnableOption "nwtelegraf";
      extraConfig = mkOption {
        default = {};
        type = types.attrs;
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
