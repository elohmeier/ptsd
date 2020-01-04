{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.dlrgVpnHost;
in
{
  options.ptsd.dlrgVpnHost = {
    enable = mkEnableOption "dlrgVpnHost";
    ip = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };

    # setup NAT eth0 <-> wgdlrg
    networking.firewall = {
      allowedUDPPorts = [ 55557 ];

      extraCommands = ''
        iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        # eth0 -> wgdlrg
        iptables -t nat -A POSTROUTING -o wgdlrg -j MASQUERADE
        iptables -A FORWARD -i eth0 -o wgdlrg -j ACCEPT

        # wgdlrg -> eth0
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        iptables -A FORWARD -i wgdlrg -o eth0 -j ACCEPT
      '';

      extraStopCommands = ''
        iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        # eth0 -> wgdlrg
        iptables -t nat -D POSTROUTING -o wgdlrg -j MASQUERADE
        iptables -D FORWARD -i eth0 -o wgdlrg -j ACCEPT

        # wgdlrg -> eth0
        iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
        iptables -D FORWARD -i wgdlrg -o eth0 -j ACCEPT
      '';
    };

    ptsd.secrets.files."dlrgvpn.key" = {};

    networking.wireguard.interfaces = {
      wgdlrg = {
        ips = [ "${cfg.ip}/24" ];
        listenPort = 55557;
        privateKeyFile = config.ptsd.secrets.files."dlrgvpn.key".path;

        peers = [

          # U.S. Handy
          {
            publicKey = "/5uhmBD09M5MK0no5aURYjeUeHFelYSoyEbs9s1l1WI=";
            allowedIPs = [ "191.18.21.2/32" ];
          }

          # mb1 / nw1
          {
            publicKey = "3SL8LpzYj4cncLpx3CEqOCmsQaJ45j9G51g41YNU+kw=";
            allowedIPs = [ "191.18.21.1/32" ];
          }

          # iph1 / nw15
          {
            publicKey = "xs4hm1bIlQ5eB5JsjbVetOvsJZ8MSVO8jSQgIpcJcy0=";
            allowedIPs = [ "191.18.21.15/32" ];
          }

          # tp1 / nw30
          {
            publicKey = "y6NCfYWUCR6aqoLsjqQRbfhz7rLqrtUOnY3HTWa0HFI=";
            allowedIPs = [ "191.18.21.30/32" ];
          }

          # apu2 / nw34
          {
            publicKey = "eQXHytFmxA8HyECId+vVaTOVE9iCaWV7KVGs5ps6glQ=";
            allowedIPs = [ "191.18.21.34/32" "192.168.168.0/24" ];
          }

        ];
      };
    };

  };
}
