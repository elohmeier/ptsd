{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.dlrgVpnClient;
in
{
  imports = [
    ./wireguard-reresolve.nix
  ];

  options.ptsd.dlrgVpnClient = {
    enable = mkEnableOption "dlrgVpnClient";
    ip = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };

    # setup NAT br0 <-> wgdlrg
    networking.firewall = {
      extraCommands = ''
        iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        # br0 -> wgdlrg
        iptables -t nat -A POSTROUTING -o wgdlrg -j MASQUERADE
        iptables -A FORWARD -i br0 -o wgdlrg -j ACCEPT

        # wgdlrg -> br0
        iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
        iptables -A FORWARD -i wgdlrg -o br0 -j ACCEPT
      '';

      extraStopCommands = ''
        iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        # br0 -> wgdlrg
        iptables -t nat -D POSTROUTING -o wgdlrg -j MASQUERADE
        iptables -D FORWARD -i br0 -o wgdlrg -j ACCEPT

        # wgdlrg -> br0
        iptables -t nat -D POSTROUTING -o br0 -j MASQUERADE
        iptables -D FORWARD -i wgdlrg -o br0 -j ACCEPT
      '';
    };

    ptsd.secrets.files."dlrgvpn.key" = {};

    networking.wireguard = {

      reresolve = [ "wgdlrg" ];

      interfaces = {
        wgdlrg = {
          ips = [ cfg.ip ];
          privateKeyFile = config.ptsd.secrets.files."dlrgvpn.key".path;
          peers = [
            {
              publicKey = "BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=";
              allowedIPs = [
                "191.18.21.0/24"
                "192.168.178.0/24"
              ];
              endpoint = "hvrhukr39ruezms4.myfritz.net:55557";
              persistentKeepalive = 21;
            }
          ];
        };
      };
    };

  };
}
