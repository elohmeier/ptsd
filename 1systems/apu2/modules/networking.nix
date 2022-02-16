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
    interfaces.br0.useDHCP = true;

    firewall = {

      interfaces.br0 = {
        allowedTCPPorts = [
          config.ptsd.mosquitto.portPlain
        ];
        allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
      };

      trustedInterfaces = [ "br0" "dlrgvpn" ];

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
