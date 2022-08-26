{ config, lib, pkgs, ... }:
let
  universe = import ./universe.nix;
in
{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = universe.hosts."${config.networking.hostName}".nets.tailscale.ip4.addr;
    port = config.ptsd.ports.prometheus-node;
    enabledCollectors = [
      "cpu"
      "conntrack"
      "diskstats"
      "entropy"
      "filefd"
      "filesystem"
      "loadavg"
      "mdadm"
      "meminfo"
      "netdev"
      "netstat"
      "stat"
      "time"
      "vmstat"
      "systemd"
      "logind"
      "interrupts"
      "ksmd"
      "textfile"
    ];
    extraFlags = [
      "--collector.textfile.directory=/var/log"
    ];
  };
}
