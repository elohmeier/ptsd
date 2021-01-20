with import <ptsd/lib>;
{ config, lib, pkgs, ... }:
let
  netcfg = import <secrets/netcfg.nix>;
  wifiIf = "wlp4s0";
  wanIf = "wwp0s19u1u3c2"; # LTE
  lanIf1 = "enp1s0"; # WAN / Fritz!Box
  lanIf2 = "enp2s0"; # LAN
  lanIf3 = "enp3s0"; # LAN
  brlanIf = "brlan";
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <ptsd/2configs/prometheus/node.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu3";
    #   vlans.vlanppp = {
    #     id = 7; # BNG
    #     interface = "enp1s0";
    #   };
    bridges."${brlanIf}".interfaces = [ lanIf2 lanIf3 ];
    interfaces = {

      #     # DSL WAN
      #     enp1s0.ipv4.addresses = [{ address = "192.168.1.2"; prefixLength = 24; }];

      #     # Printer
      #     enp2s0.ipv4.addresses = [{ address = "192.168.2.1"; prefixLength = 24; }];

      #     # LTE WAN
      #     enp0s18f2u1 = {
      #       useDHCP = true;
      #     };

      # WAN Fritz!Box
      "${lanIf1}" = {
        useDHCP = true;
      };

      # LAN/WIFI
      "${brlanIf}".ipv4.addresses = [{ address = "192.168.123.1"; prefixLength = 24; }];

      #     vlanppp = {
      #       useDHCP = false;
      #     };
    };
    firewall = {
      #     interfaces.enp2s0.allowedUDPPorts = [ 67 68 546 547 ];
      interfaces."${brlanIf}" = {
        allowedTCPPorts = [ 53 631 445 139 ];
        allowedUDPPorts = [ 53 67 68 546 547 631 137 138 ];
      };

      #     # reduce noise coming from ppp if
      #     logRefusedConnections = false;

      #     # useful for debugging
      #     # logRefusedPackets = true;
      #     # logRefusedUnicastsOnly = false;
      #     # logReversePathDrops = true;
    };
    nat = {
      enable = true;
      externalInterface = lanIf1;
      internalInterfaces = [ brlanIf ];
    };
  };

  systemd.network.networks = {
    #   "40-vlanppp".networkConfig.LinkLocalAddressing = "no";
    #   "40-enp0s18f2u1".dhcpV4Config.UseRoutes = false; # existing default routes will prevent ppp0 from creating a default route
    "40-${lanIf1}" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-${lanIf2}" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-${lanIf3}" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-${brlanIf}" = {
      networkConfig = {
        #IPv6AcceptRA = false;
        #IPv6PrefixDelegation = "dhcpv6";
        #IPv6DuplicateAddressDetection = 1;
        #IPv6PrivacyExtensions = lib.mkForce "no";
        DHCPServer = true; # ipv4, see dhcpServerConfig below
      };
      ipv6PrefixDelegationConfig = {
        #RouterLifetimeSec = 300; # required as otherwise no RA's are being emitted
      };
      dhcpServerConfig = {
        PoolOffset = 100;
        PoolSize = 20;
        EmitDNS = "yes";
        DNS = "8.8.8.8";
      };
    };
    "40-${wifiIf}" = {
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    #   "40-ppp0" = {
    #     name = "ppp0";
    #     networkConfig = {
    #       DHCP = "ipv6";
    #       IPv6AcceptRA = "yes";
    #       KeepConfiguration = "yes"; # accept config set by pppd
    #     };
    #     dhcpV6Config = {
    #       ForceDHCPv6PDOtherInformation = "yes";
    #     };
    #   };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
  };

  services.hostapd = {
    enable = true;
    interface = wifiIf;
    ssid = "SVB";
    wpaPassphrase = netcfg.wifi.passphrase;
    countryCode = "DE";
    extraConfig = ''
      wpa_pairwise=CCMP
      bridge=${brlanIf}
    '';
  };

  # services.samba = {
  #   enable = true;
  #   securityType = "user";
  #   extraConfig = ''
  #     workgroup = WORKGROUP
  #     server string = ${config.networking.hostName}
  #     netbios name = ${config.networking.hostName}
  #     security = user
  #     hosts allow = 192.168.123.0/24
  #     hosts deny = 0.0.0.0/0
  #   '';
  # };

  # services.pppd = {
  #   enable = true;
  #   peers.telekom = {
  #     enable = true;
  #     autostart = true;
  #     config = ''
  #       plugin rp-pppoe.so vlanppp

  #       # Login settings.
  #       name "${netcfg.dsl.username}"
  #       noauth
  #       hide-password

  #       # Connection settings.
  #       persist
  #       maxfail 0
  #       holdoff 5

  #       # LCP settings.
  #       lcp-echo-interval 10
  #       lcp-echo-failure 3

  #       # PPPoE compliant settings.
  #       noaccomp
  #       default-asyncmap
  #       mtu 1492

  #       # IP settings.
  #       noipdefault
  #       defaultroute
  #       +ipv6
  #       defaultroute6

  #       # Increase debugging level
  #       # debug
  #     '';
  #   };
  # };

  # environment.etc."ppp/chap-secrets" =
  #   {
  #     text = ''"${netcfg.dsl.username}" * "${netcfg.dsl.password}" *'';
  #     mode = "0400";
  #   };

  environment.systemPackages = with pkgs; [ tmux htop bridge-utils ];

  security.sudo.wheelNeedsPassword = false;

  programs.mosh.enable = true;
}
