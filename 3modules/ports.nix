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
      acme-dns-dns = 10001;
      acme-dns-http = 10002;
      alertmanager = 10003;
      bitwarden = 10004;
      fraam-wordpress = 10005;
      fraam-wwwstatic = 10006;
      fraamdb = 10007;
      gitweb = 10008;
      gowpcontactform = 10009;
      grafana = 10010;
      home-assistant = 10011;
      loki = 10012;
      mjpg-streamer = 10013;
      navidrome = 10014;
      nerdworkswww = 10015;
      nginx-kanboard = 10016;
      nginx-monica = 10017;
      nginx-nwacme = 10018;
      nginx-tsindex = 10019;
      nginx-wellknown-matrix = 10020;
      nwgit = 10021;
      octoprint = 10022;
      photoprism = 10023;
      prometheus-maddy = 10024;
      prometheus-node = 10025;
      prometheus-quotes-exporter = 10026;
      prometheus-server = 10027;
      radicale = 10028;
      redis-rspamd = 10029;
      synapse = 10030;
    };
  };
}
