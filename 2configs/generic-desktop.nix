{ config, lib, pkgs, ... }:

with lib;
let

in
{
  networking.wireless.iwd.enable = mkDefault true;

  systemd.network.networks = {
    eth = {
      dhcpV4Config.RouteMetric = 10;
      ipv6AcceptRAConfig.RouteMetric = 10;
      linkConfig.RequiredForOnline = "no";
      matchConfig.Type = "ether";
      networkConfig = { ConfigureWithoutCarrier = true; DHCP = "yes"; };
    };
    wlan = mkIf config.networking.wireless.iwd.enable {
      dhcpV4Config.RouteMetric = 20;
      ipv6AcceptRAConfig.RouteMetric = 20;
      matchConfig.Type = "wlan";
      networkConfig.DHCP = "yes";
    };
  };

  time.timeZone = "Europe/Berlin";
}
