{ config, lib, pkgs, ... }:

with import <ptsd/lib>;
let
  universe = import <ptsd/2configs/universe.nix>;
  vpnNodes = netname: filterAttrs (hostname: hostcfg: hostname != config.networking.hostName && hasAttrByPath [ "nets" netname ] hostcfg) universe.hosts;

  blackboxConfigJSON = pkgs.writeText "blackbox.json"
    (
      builtins.toJSON {
        modules = {
          https_2xx = {
            prober = "http";
            http = {
              fail_if_not_ssl = true;
            };
          };
        };
      }
    );
  blackboxConfigFile = pkgs.runCommand "blackbox.yaml" { preferLocalBuild = true; } ''
    ${pkgs.remarshal}/bin/json2yaml -i ${blackboxConfigJSON} -o $out
  '';
in
{
  # access via localhost
  #networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ 9090 9093 ];

  services.prometheus = {
    enable = true;
    extraFlags = [
      "--storage.tsdb.retention.time 720h" # 30d
    ];

    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "10s";

        # scrape all nwvpn hosts
        static_configs = (
          mapAttrsToList (
            hostname: hostcfg: {
              targets = [
                "${hostcfg.nets.nwvpn.ip4.addr}:9100"
              ];
              labels = {
                alias = hostname;
              };
            }
          ) (vpnNodes "nwvpn")
        );
      }
      {
        job_name = "blackbox";
        scrape_interval = "10s";
        metrics_path = "/probe";
        params.module = [ "https_2xx" ];
        static_configs = [
          {
            targets = [
              "https://grafana.services.nerdworks.de"
              "https://hass.services.nerdworks.de"
              "https://nextcloud.services.nerdworks.de"
              "https://www.nerdworks.de"
            ];
          }
        ];
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "localhost:9115"; # blackbox exporter's address
          }
        ];
      }
    ];

    exporters.blackbox = {
      enable = true;
      configFile = blackboxConfigFile;
    };
  };
}
