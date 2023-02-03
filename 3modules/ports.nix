{ config, lib, ... }:

with lib;
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
      paperless = 28981;
      photoprism = 2342;
      prometheus-maddy = 9749;
      prometheus-node = 9100;
      prometheus-pushgateway = 9091;
      prometheus-rspamd = 7980;
      prometheus-server = 9090;
      prometheus-mysqld = 9104;

      # internal
      prometheus-quotes-exporter = 10003;
      redis-rspamd = 10004;
      synapse = 10005;
      ustreamer = 10006;
    };
  };
}
