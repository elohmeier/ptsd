{ config, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/hardened.nix
    ../../2configs/nwhost-mini.nix

    ../../2configs/prometheus/node.nix
  ];

  ptsd.wireguard = {
    enableGlobalForwarding = true;
    networks.dlrgvpn = {
      enable = true;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      natForwardIf = "eth0"; # not sure if really needed (is it routing or NATing?), kept for backward compatibility
      server.enable = true;
      routes = [
        { routeConfig = { Destination = "192.168.168.0/24"; }; }
      ];
    };
  };

  ptsd.nwbackup = {
    enable = true;
  };

  # fix often full /boot directory
  boot.loader.grub.configurationLimit = 2;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi2";
    interfaces.eth0.useDHCP = true;
  };
}
