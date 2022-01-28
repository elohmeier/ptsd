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
      enablePsk = true;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      client.allowedIPs = [ "192.168.178.0/24" ];
      routes = [
        { routeConfig = { Destination = "192.168.178.0/24"; }; }
      ];
    };
  };

  ptsd.secrets.files."dlrgvpn.psk" = {
    owner = "systemd-network";
    mode = "0440";
    dependants = [ "systemd-networkd.service" ];
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu2";
    bridges.br0.interfaces = bridgeIfs;
    interfaces.br0.useDHCP = true;

    firewall =
      let
        forwardSipToFritzbox = dir: ''
          iptables -${dir} PREROUTING -t nat -p tcp -i br0 --dport 5060 -j DNAT --to 192.168.178.1:5060
          iptables -${dir} PREROUTING -t nat -p udp -i br0 --dport 5060 -j DNAT --to 192.168.178.1:5060
          iptables -${dir} FORWARD -p tcp -d 192.168.178.1 --dport 5060 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
          iptables -${dir} FORWARD -p udp -d 192.168.178.1 --dport 5060 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
          iptables -${dir} POSTROUTING -t nat -p tcp -d 192.168.178.1 --dport 5060 -j MASQUERADE
          iptables -${dir} POSTROUTING -t nat -p udp -d 192.168.178.1 --dport 5060 -j MASQUERADE
        '';
      in
      {
        # extraCommands = forwardSipToFritzbox "A";
        # extraStopCommands = forwardSipToFritzbox "D";

        interfaces.br0 = {
          allowedTCPPorts = [
            5060 # SIP
            config.ptsd.mosquitto.portPlain
          ];
          allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
          allowedUDPPorts = [ 5060 ]; # SIP
          allowedUDPPortRanges = [{ from = config.services.siproxd.rtpPortLow; to = config.services.siproxd.rtpPortHigh; }];
        };

        allowedTCPPorts = [
          8123 # hass
        ];
      };
  };

  services.siproxd = {
    enable = true;
    ifInbound = "br0";
    ifOutbound = "dlrgvpn";
    hostsAllowReg = [ "192.168.168.1/32" ];
    hostsAllowSip = [ "192.168.168.1/32" ];
  };
  users.users.siproxyd.group = "siproxyd";
  users.groups.siproxyd = { };

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
