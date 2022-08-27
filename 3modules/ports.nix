{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.ports;
in
{
  options = {
    ptsd.ports = mkOption {
      internal = true;
      description = "well-known ports in ptsd";
      type = types.attrsOf types.int;
    };
  };

  config = {
    ptsd.ports = {
      # user-facing / well-known via tailscale
      alertmanager = 9093;
      grafana = 3000;
      home-assistant = 8123;
      loki = 3100;
      mjpg-streamer = 5001;
      monica = 8485;
      navidrome = 4533;
      octoprint = 5000;
      prometheus-maddy = 9749;
      prometheus-node = 9100;
      prometheus-pushgateway = 9091;
      prometheus-server = 9090;

      # internal
      bitwarden = 10000;
      fraamdb = 10001;
      photoprism = 10002;
      prometheus-quotes-exporter = 10003;
      redis-rspamd = 10004;
      synapse = 10005;
    };
  };
}
