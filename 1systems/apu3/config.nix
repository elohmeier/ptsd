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
    bridges."${brlanIf}".interfaces = [ lanIf2 lanIf3 ];
    interfaces = {
      # WAN Fritz!Box
      "${lanIf1}" = {
        useDHCP = true;
      };

      # LAN/WIFI
      "${brlanIf}".ipv4.addresses = [{ address = "192.168.123.1"; prefixLength = 24; }];

      # LTE WAN
      enp0s16u2 = {
        useDHCP = true;
      };
    };
    firewall = {
      interfaces = {
        "${brlanIf}" = {
          allowedTCPPorts = [ 53 631 445 139 ];
          allowedUDPPorts = [ 53 67 68 546 547 631 137 138 ];
        };
        "${lanIf1}" = {
          allowedTCPPorts = [ 445 139 ];
          allowedUDPPorts = [ 137 138 ];
        };
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
      externalInterface = "ppp0";
      #externalInterface = "enp0s16u2";
      #externalInterface = lanIf1;
      internalInterfaces = [ brlanIf ];
    };
  };

  systemd.network.networks = {
    #   "40-enp0s18f2u1".dhcpV4Config.UseRoutes = false; # existing default routes will prevent ppp0 from creating a default route
    "40-${lanIf1}" = {
      dhcpV4Config.UseRoutes = false; # allows pppd to set default route
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
    "40-ppp0" = {
      name = "ppp0";
      networkConfig = {
        KeepConfiguration = "yes"; # accept config set by pppd
      };
    };
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

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.0.0/16
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      SVB-Koetter = {
        path = "/data/SVB-Koetter";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
      Scans = {
        path = "/data/Scans";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  services.syncthing = {
    enable = true;

    declarative = {
      key = "/run/keys/syncthing.key";
      cert = "/run/keys/syncthing.crt";
      devices = {
        #homepc = { id = "xxx"; };
      };
      folders = {
        "/data/SVB-Koetter" = {
          id = "svb-koetter";
        };
      };
    };
  };

  users.users = {
    "c.koetter" = { };
    "m.nieporte" = { };
    "scanner" = { };
  };


  # useful commands for `screen /dev/ttyUSB0 115200`
  # AT+CPIN? //Check if SIM is PIN locked
  # AT+COPS?
  # AT+CFUN? //Check module status
  # ATI //Check firmware version.
  services.pppd =
    let
      chatfile = pkgs.writeText "ppp.chat" ''
        ABORT 'BUSY'
        ABORT 'NO CARRIER'
        ABORT 'VOICE'
        ABORT 'NO DIALTONE'
        ABORT 'NO DIAL TONE'
        ABORT 'NO ANSWER'
        ABORT 'DELAYED'
        REPORT CONNECT
        TIMEOUT 10
        ''' 'ATQ0'
        'OK-AT-OK' 'ATZ'
        TIMEOUT 3
        'OK-AT-OK' 'ATI'
        'OK' 'AT+CFUN=1'
        'OK' 'AT+CMEE=2'
        'OK' 'AT+CSQ'
        'OK' 'AT+CGDCONT=1,"IP","internet.telekom"'
        TIMEOUT 10
        'OK' 'ATDT*99***1#'
        TIMEOUT 3
        CONNECT '''
      '';
    in
    {
      enable = true;
      # see https://telekomhilft.telekom.de/t5/Blog/Neuer-IPv6-Zugang-zum-mobilen-Internet-im-Netz-der-Telekom/ba-p/4254741
      # and https://github.com/blu3bird/OpenHybrid
      peers.telekom = {
        enable = true;
        autostart = true;
        config = ''
          /dev/ttyUSB0
          115200

          # Login settings
          noauth
          hide-password
          user "congstar"
          remotename telekom
          ipparam telekom

          # Connection settings
          connect "${pkgs.ppp}/bin/chat -v -f ${chatfile}"
          persist
          maxfail 0
          holdoff 5
          nodeflate

          # IP settings
          noipdefault
          noipv6
          defaultroute

          # Increase debugging level
          debug
        '';
      };
    };

  environment.etc."ppp/pap-secrets" =
    {
      text = ''"congstar" telekom "cs"'';
      mode = "0400";
    };

  environment.systemPackages = with pkgs; [ tmux htop bridge-utils vim screen samba iftop ];

  programs.mosh.enable = true;
}
