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
      } // lib.optionalAttrs (cfg.inputs.file != []) { file = cfg.inputs.file; }
      // lib.optionalAttrs (cfg.inputs.http != []) { http = cfg.inputs.http; }
      // lib.optionalAttrs (cfg.inputs.http_response != []) { http_response = cfg.inputs.http_response; }
      // lib.optionalAttrs (cfg.inputs.influxdb != []) { influxdb = cfg.inputs.influxdb; }
      // lib.optionalAttrs (cfg.inputs.wireguard != []) { wireguard = cfg.inputs.wireguard; }
      // lib.optionalAttrs (cfg.inputs.x509_cert != []) { x509_cert = cfg.inputs.x509_cert; };
    };

  configFile = pkgs.runCommand "config.toml" {
    buildInputs = [ pkgs.remarshal ];
    preferLocalBuild = true;
  } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "config.json" (builtins.toJSON configOptions)} \
      > $out
  '';
in
{

  options = {
    ptsd.nwtelegraf = {
      enable = mkEnableOption "nwtelegraf";
      package = mkOption {
        default = pkgs.telegraf;
        type = types.package;
      };
      influxPassword = mkOption { type = types.str; };
      inputs = mkOption {
        type = types.submodule {
          options = {
            # extend as needed
            file = mkOption { type = types.listOf types.attrs; default = []; };
            http = mkOption { type = types.listOf types.attrs; default = []; };
            http_response = mkOption { type = types.listOf types.attrs; default = []; };
            influxdb = mkOption { type = types.listOf types.attrs; default = []; };
            wireguard = mkOption { type = types.listOf types.attrs; default = []; };
            x509_cert = mkOption { type = types.listOf types.attrs; default = []; };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.telegraf = {
      description = "Telegraf Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/telegraf -config "${configFile}"'';
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        DynamicUser = true;
        Restart = "on-failure";
        TimeoutStopSec = "10s";
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        NoNewPrivileges = true;
      } // optionalAttrs (cfg.inputs.wireguard != []) {
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";
      };
    };
  };
}
