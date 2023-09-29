{ lib, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = lib.mkDefault "$''{HETZNER_PRIVATE_IPV4_0}";
    port = 9100;
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
  };

  systemd.services.prometheus-node-exporter = {
    after = [ "hcloud-netcfg.service" ];
    wants = [ "hcloud-netcfg.service" ];
    serviceConfig.EnvironmentFile = "/etc/hcloud.env";
  };
}
