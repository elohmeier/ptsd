{ config, lib, pkgs, ... }:

let
  universe = import ../../../2configs/universe.nix;
in
{
  services.avahi.enable = true;

  networking = {
    hostName = "ws1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.eth0.useDHCP = true; # wifi if

    # bridges.br0.interfaces = [ "enp39s0" ];
    # interfaces.br0.useDHCP = true;
    interfaces.enp39s0.useDHCP = true;

    # hosts."10.129.127.250" = [ "s3.bucket.htb" "bucket.htb" ];

    wireless.iwd.enable = true;

    firewall.interfaces = {
      eth0 = {
        allowedTCPPorts = [ 3389 ]; # for optional rdp forwarding
      };
      enp39s0.allowedUDPPorts = [ 67 68 ]; # DHCPServer
    };

    nat = {
      enable = true;
      externalInterface = "enp39s0"; # wired

      # externalInterface = "eth0"; # wireless
      #   internalInterfaces = [ "enp39s0" ]; # useful for wired dhcp, see below
    };
  };

  # start wifi manually
  systemd.services.iwd.wantedBy = lib.mkForce [ ];

  ptsd.secrets.files."Bundesdatenschutzzentrale 5GHz.psk" = {
    path = "/var/lib/iwd/Bundesdatenschutzzentrale 5GHz.psk";
  };

  systemd.network = {
    networks = {

      # wireless
      "40-eth0" = {
        routes = [
          {
            routeConfig = {
              Destination = "${universe.hosts.nas1.nets.nwvpn.ip4.addr}/32";
              Gateway = universe.hosts.nas1.nets.bs53lan.ip4.addr;
              GatewayOnLink = "yes";
            };
          }
        ];

        dhcpV4Config.RouteMetric = 20;
      };

      # wired
      "40-enp39s0" = {
        matchConfig = {
          Name = "enp39s0";
        };

        linkConfig = {
          RequiredForOnline = "no";
        };

        networkConfig = {
          ConfigureWithoutCarrier = true;

          # DHCP
          # Address = "192.168.123.1/24";
          # DHCPServer = true;
        };

        dhcpV4Config.RouteMetric = 10;
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    #   extraConfig = ''
    #     [Resolve]
    #     DNS=127.0.0.1:5053
    #     Domains=~htb
    #   '';
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  # boot.kernelParams = [ "ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:enp39s0:off" ];

  # ptsd.wireguard.networks.fraam_buero_vpn = {
  #   enable = true;
  #   ip = universe.hosts."${config.networking.hostName}".nets.fraam_buero_vpn.ip4.addr;
  #   keyname = "nwvpn.key";
  # };

  # ptsd.wireguard.networks = {
  #   dlrgvpn = {
  #     enable = true;
  #     ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
  #     client.allowedIPs = [ "192.168.168.0/24" ];
  #     routes = [
  #       { routeConfig = { Destination = "192.168.168.0/24"; }; }
  #     ];
  #     keyname = "nwvpn.key";
  #   };
  # };
}
