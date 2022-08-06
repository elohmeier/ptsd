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
      natForwardIf = "bond0";
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
      interfaces.bond0 = {
        allowedTCPPorts = [ 1883 ]; # mosquitto
        allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
      };
      trustedInterfaces = [ "bond0" "dlrgvpn" "nwvpn" "tailscale0" ];
      allowedTCPPorts = [
        8123 # hass
      ];
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "40-bond0" = {
        netdevConfig = { Kind = "bond"; Name = "bond0"; };
        bondConfig.Mode = "active-backup";
      };
    };
    networks = {
      "40-bond0" = {
        matchConfig.Name = "bond0";
        networkConfig.Address = "192.168.168.41/24"; # fix wrong ip address allocation after nixos 22.05 upgrade
        routes = [{ routeConfig.Gateway = "192.168.168.1"; }];
      };
      "40-enp" = {
        matchConfig.Name = "enp*";
        networkConfig = { Bond = "bond0"; ConfigureWithoutCarrier = true; };
      };
    };
  };
}
