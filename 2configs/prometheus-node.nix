{ config, lib, pkgs, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
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
