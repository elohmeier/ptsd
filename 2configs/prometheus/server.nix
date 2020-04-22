{ config, lib, pkgs, ... }:

with import <ptsd/lib>;
let
  universe = import <ptsd/2configs/universe.nix>;
  vpnNodes = netname: filterAttrs (hostname: hostcfg: hostname != config.networking.hostName && hasAttrByPath [ "nets" netname ] hostcfg) universe.hosts;
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
    ];
  };
}
