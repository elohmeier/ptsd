with import <ptsd/lib>;
{ config, lib, pkgs, ... }:
let
  netcfg = import <secrets/netcfg.nix>;
in
{
  # INFO: Remember there is an unused drive /dev/sda2 (/srv) installed.

  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/acme-nwhost-cert.nix>
    <ptsd/2configs/nwhost-mini.nix>
    <ptsd/2configs/prometheus/node.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu1";
    vlans.vlanppp = {
      id = 7; # BNG
      interface = "enp1s0";
    };
    interfaces = {

      # DSL WAN
      enp1s0.ipv4.addresses = [{ address = "192.168.1.2"; prefixLength = 24; }];

      # Printer
      enp2s0.ipv4.addresses = [{ address = "192.168.2.1"; prefixLength = 24; }];

      # LTE WAN
      enp0s18f2u1 = {
        useDHCP = true;
      };

      wlp4s0 = {
        ipv4.addresses = [{ address = "192.168.123.1"; prefixLength = 24; }];
        # ipv6.addresses
      };

      vlanppp = {
        useDHCP = false;
      };
    };
    firewall = {
      interfaces.enp2s0.allowedUDPPorts = [ 67 68 546 547 ];
      interfaces.wlp4s0 = {
        allowedTCPPorts = [ 53 631 445 139 ];
        allowedUDPPorts = [ 53 67 68 546 547 631 137 138 ];
      };

      # useful for debugging
      logRefusedPackets = true;
      logRefusedUnicastsOnly = false;
      logReversePathDrops = true;
    };
    nat = {
      enable = true;
      #externalInterface = "enp0s18f2u1";
      externalInterface = "ppp0";
      internalInterfaces = [ "wlp4s0" ];
    };
  };

  systemd.network.networks = {
    "40-vlanppp".networkConfig.LinkLocalAddressing = "no";
    "40-enp0s18f2u1".dhcpV4Config.UseRoutes = false; # existing default routes will prevent ppp0 from creating a default route
    # "40-wlp4s0".networkConfig = {
    #   IPv6PrefixDelegation = "dhcpv6";
    #   IPv6DuplicateAddressDetection = 1;
    #   IPv6PrivacyExtensions = lib.mkForce "no";
    # };
  };

  services.hostapd = {
    enable = true;
    interface = "wlp4s0";
    ssid = "fraam";
    wpaPassphrase = netcfg.wifi.passphrase;
    countryCode = "DE";
    extraConfig = ''
      wpa_pairwise=CCMP
    '';
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      interface=wlp4s0,enp2s0
      bind-interfaces

      # don't send bogus requests out on the internets
      bogus-priv

      # Enable dnsmasq's IPv6 Router Advertisement feature
      enable-ra

      # printer net
      dhcp-range=enp2s0,192.168.2.10,192.168.2.150,12h

      # fixed ip for printer
      dhcp-host=enp2s0,00:1b:a9:f9:e3:41,192.168.2.2,12h

      # wifi
      dhcp-range=wlp4s0,192.168.123.10,192.168.123.150,12h
      #dhcp-range=wlp4s0,::1,::ffff,constructor:ppp0,ra-names,slaac,12h

      dhcp-authoritative
      cache-size=5000
    '';
  };

  hardware.printers = {
    ensureDefaultPrinter = "HL5380DN";
    ensurePrinters = [
      {
        name = "HL5380DN";
        deviceUri = "socket://192.168.2.2:9100";
        model = "drv:///brlaser.drv/br5030.ppd";
        ppdOptions = {
          PageSize = "A4";
          Resolution = "600dpi";
          InputSlot = "Auto";
          MediaType = "PLAIN";
          brlaserEconomode = "False";
        };
      }
    ];
  };

  ptsd.cups-airprint = {
    enable = true;
    listenAddress = "192.168.123.1:631";
    printerName = "HL5380DN";
  };

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.123.0/24
      hosts deny = 0.0.0.0/0
    '';
  };

  services.pppd = {
    enable = true;
    peers.telekom = {
      enable = true;
      autostart = true;
      config = ''
        plugin rp-pppoe.so vlanppp

        # The name of user
        name "${netcfg.dsl.username}"

        # If "noipdefault" is given the peer will have to supply an IP address
        noipdefault

        # Enable the IPv6CP and IPv6 protocols
        +ipv6

        # Add a default route to the system routing tables, using the peer as the gateway
        defaultroute

        # Add a default IPv6 route to the system routing tables, using the peer as the gateway
        defaultroute6

        # Do not exit after a connection is terminated; instead try to reopen the connection
        persist

        # Do not require the peer to authenticate itself
        noauth

        # Increase debugging level
        # debug
      '';
    };
  };
  environment.etc."ppp/chap-secrets" =
    {
      text = ''"${netcfg.dsl.username}" * "${netcfg.dsl.password}" *'';
      mode = "0400";
    };

  environment.systemPackages = with pkgs; [ tmux htop ];
}
