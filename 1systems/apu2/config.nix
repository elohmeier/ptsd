with import <ptsd/lib>;
{ config, pkgs, ... }:
let
  bridgeIfs = [
    "enp1s0"
    "enp2s0"
    "enp3s0"
  ];
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/nwhost.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  ptsd.wireguard.networks.dlrgvpn = {
    enable = true;
    ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
    natForwardIf = "br0";
    client.allowedIPs = [ "192.168.178.0/24" ];
    routes = [
      { routeConfig = { Destination = "192.168.178.0/24"; }; }
    ];
  };

  ptsd.nwbackup = {
    enable = true;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu2";
    bridges.br0.interfaces = bridgeIfs;
    interfaces.br0.useDHCP = true;
  };

  systemd.network.networks = builtins.listToAttrs (
    map (
      brName: {
        name = "40-${brName}";
        value = {
          networkConfig = {
            ConfigureWithoutCarrier = true;
          };
        };
      }
    ) bridgeIfs
  );

  services.home-assistant = {
    enable = true;
    package = pkgs.nwhass;
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  networking.firewall.allowedTCPPortRanges = [ { from = 30000; to = 50000; } ]; # for pyhomematic

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://192.168.168.41:8123" ];
        response_string_match = "Home Assistant";
      }
    ];
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check host 192.168.168.41 with address 192.168.168.41
        if failed
          port 8123
          protocol http
          content = "Home Assistant"
        then alert
    ''
  ];
}
