{ config, lib, pkgs, ... }:
let
  universe = import ../universe.nix;
in
{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = universe.hosts."${config.networking.hostName}".nets.tailscale.ip4.addr;
    port = config.ptsd.ports.prometheus-node;
    enabledCollectors = import ./node_collectors.nix;
    extraFlags = [
      "--collector.textfile.directory=/var/log"
    ];
  };
}
