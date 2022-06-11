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
      home-assistant = 8123; # TODO: update yaml like in octoprint module
      loki = 10012;
      mjpg-streamer = 10013;
      navidrome = 10014;
      nerdworkswww = 10015;
      nginx-fraam-intweb = 10017;
      nginx-fraam-git = 10018;
      nginx-kanboard = 10019;
      nginx-monica = 10020;
      nginx-nwacme = 10021;
      nginx-wellknown-matrix = 10022;
      nwgit = 10023;
      octoprint = 10024;
      photoprism = 10025;
      prometheus-gitlab = 10026;
      prometheus-maddy = 10027;
      prometheus-node = 10028;
      prometheus-quotes-exporter = 10029;
      prometheus-server = 10030;
      radicale = 10031;
      redis-rspamd = 10032;
      synapse = 10033;
      nginx-tsindex = 10034;
    };
  };
}
