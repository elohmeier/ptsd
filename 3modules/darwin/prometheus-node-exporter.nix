{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.node-exporter;
in

{
  options = {
    ptsd.node-exporter = {
      enable = mkEnableOption "the prometheus node exporter";
      port = mkOption {
        type = types.port;
        default = 9100;
        description = ''
          Port to listen on.
        '';
      };
      listenAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = ''
          Address to listen on.
        '';
      };
      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Extra commandline options to pass to the node exporter.
        '';
      };
      enabledCollectors = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = ''[ "systemd" ]'';
        description = ''
          Collectors to enable. The collectors listed here are enabled in addition to the default ones.
        '';
      };
      disabledCollectors = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = ''[ "timex" ]'';
        description = ''
          Collectors to disable which are enabled by default.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.prometheus-node-exporter ];

    launchd.daemons.node-exporter = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.prometheus-node-exporter}/bin/node_exporter" ]
          ++ (map (x: "--collector." + x) cfg.enabledCollectors)
          ++ (map (x: "--no-collector." + x) cfg.disabledCollectors)
          ++ [
          "--web.listen-address"
          "${cfg.listenAddress}:${toString cfg.port}"
        ] ++ cfg.extraFlags;
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}
