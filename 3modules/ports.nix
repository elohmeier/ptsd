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
      nextcloud = 10016;
      nginx-fraam-intweb = 10017;
      nginx-kanboard = 10018;
      nginx-monica = 10019;
      nginx-nwacme = 10020;
      nginx-wellknown-matrix = 10021;
      nwgit = 10022;
      octoprint = 10023;
      photoprism = 10024;
      prometheus-gitlab = 10025;
      prometheus-maddy = 10026;
      prometheus-node = 10027;
      prometheus-quotes-exporter = 10028;
      prometheus-server = 10029;
      radicale = 10030;
      synapse = 10031;
    };
  };
}
