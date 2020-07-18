{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ 9100 ];

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
    enabledCollectors = [
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
    ];
  };
}
