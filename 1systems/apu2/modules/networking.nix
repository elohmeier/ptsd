{ config, lib, pkgs, ... }:
let
  bridgeIfs = [
    "enp1s0"
    "enp2s0"
    "enp3s0"
  ];
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
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu2";
    bridges.br0.interfaces = bridgeIfs;
    interfaces.br0.useDHCP = false;

    # fix wrong ip address allocation after nixos 22.05 upgrade
    interfaces.br0.ipv4.addresses = [{ address = "192.168.168.41"; prefixLength = 24; }];
    defaultGateway = "192.168.168.1";
    nameservers = [ "192.168.168.1" ];

    firewall = {

      interfaces.br0 = {
        allowedTCPPorts = [
          config.ptsd.mosquitto.portPlain
        ];
        allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
      };

      trustedInterfaces = [ "br0" "dlrgvpn" "nwvpn" "tailscale0" ];

      allowedTCPPorts = [
        8123 # hass
      ];
    };
  };

  systemd.network.networks = builtins.listToAttrs (
    map
      (
        brName: {
          name = "40-${brName}";
          value = {
            networkConfig = {
              ConfigureWithoutCarrier = true;
            };
          };
        }
      )
      bridgeIfs
  );
}
