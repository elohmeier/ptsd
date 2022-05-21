{ config, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/prometheus/node.nix
  ];

  ptsd.wireguard = {
    enableGlobalForwarding = true;
    networks.dlrgvpn = {
      enable = true;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      natForwardIf = "eth0";
      server.enable = true;
      routes = [
        { routeConfig = { Destination = "192.168.168.0/24"; }; }
      ];
    };
  };

  ptsd.nwacme.enable = false;
  ptsd.nwbackup.enable = false;
  ptsd.neovim.enable = false;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi2";
    interfaces.eth0.useDHCP = true;
    wireless.enable = true;
  };

  systemd.network.networks."40-eth0" = {
    matchConfig = {
      Name = "eth0";
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      ConfigureWithoutCarrier = true;
    };
  };
}
