{ config, lib, pkgs, ... }:
let
  universe = import ../../../2configs/universe.nix;
in
{
  ptsd.wireguard = {
    enableGlobalForwarding = true;
    networks.dlrgvpn = {
      enable = true;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      natForwardIf = "br0";
      client.allowedIPs = [ "192.168.178.0/24" ];
      routes = [
        { routeConfig = { Destination = "192.168.178.0/24"; }; }
      ];
    };
  };

  networking = {
    hostName = "apu2";
    useDHCP = false;
    useNetworkd = true;
    nameservers = [ "192.168.168.1" ];

    firewall = {
      interfaces.br0 = {
        allowedTCPPorts = [ 1883 ]; # mosquitto
        allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
      };
      trustedInterfaces = [ "br0" "dlrgvpn" "nwvpn" "tailscale0" ];
      allowedTCPPorts = [
        8123 # hass
      ];
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "40-br0".netdevConfig = { Kind = "bridge"; Name = "br0"; };
    };
    networks = {
      "40-br0" = {
        matchConfig.Name = "br0";
        networkConfig = { DHCP = "ipv6"; Address = "192.168.168.41/24"; }; # fix wrong ip address allocation after nixos 22.05 upgrade
        routes = [{ routeConfig.Gateway = "192.168.168.1"; }];
      };
      "40-enp" = {
        matchConfig.Name = "enp*";
        networkConfig = { Bridge = "br0"; ConfigureWithoutCarrier = true; };
      };
    };
  };
}
