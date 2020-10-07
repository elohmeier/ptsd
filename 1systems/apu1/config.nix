with import <ptsd/lib>;
{ config, pkgs, ... }:
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

      wlp4s0.ipv4.addresses = [{ address = "192.168.123.1"; prefixLength = 24; }];

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
      externalInterface = "enp0s18f2u1";
      internalInterfaces = [ "wlp4s0" ];
    };
  };

  # TODO: update with https://wiki.gentoo.org/wiki/Hostapd
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
    extraConfig = ''
      interface=wlp4s0,enp2s0
      dhcp-range=enp2s0,192.168.2.10,192.168.2.150,12h
      dhcp-host=enp2s0,00:1b:a9:f9:e3:41,192.168.2.2,12h
      dhcp-range=wlp4s0,192.168.123.10,192.168.123.150,12h
      bind-interfaces
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
        name "${netcfg.dsl.username}"
        noipdefault
        persist
        noauth
        debug
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
