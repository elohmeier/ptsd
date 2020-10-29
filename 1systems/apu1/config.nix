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

      # nuc1
      enp3s0.ipv4.addresses = [{ address = "192.168.124.1"; prefixLength = 24; }];

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
      interfaces.enp3s0 = {
        allowedTCPPorts = [ 53 631 445 139 ];
        allowedUDPPorts = [ 53 67 68 546 547 631 137 138 ];
      };
      interfaces.wlp4s0 = {
        allowedTCPPorts = [ 53 631 445 139 ];
        allowedUDPPorts = [ 53 67 68 546 547 631 137 138 ];
      };

      # reduce noise coming from ppp if
      logRefusedConnections = false;

      # useful for debugging
      # logRefusedPackets = true;
      # logRefusedUnicastsOnly = false;
      # logReversePathDrops = true;
    };
    nat = {
      enable = true;
      #externalInterface = "enp0s18f2u1";
      externalInterface = "ppp0";
      internalInterfaces = [ "enp3s0" "wlp4s0" ];
    };
  };

  systemd.network.networks = {
    "40-vlanppp".networkConfig.LinkLocalAddressing = "no";
    "40-enp0s18f2u1".dhcpV4Config.UseRoutes = false; # existing default routes will prevent ppp0 from creating a default route
    "40-enp1s0" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-enp2s0" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-enp3s0" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
        IPv6AcceptRA = false;
        IPv6PrefixDelegation = "dhcpv6";
        IPv6DuplicateAddressDetection = 1;
        IPv6PrivacyExtensions = lib.mkForce "no";
        # DHCPServer = true; # ipv4, see dhcpServerConfig below. disabled in favour of dnsmasq.
      };
      ipv6PrefixDelegationConfig = {
        RouterLifetimeSec = 300; # required as otherwise no RA's are being emitted
      };
      # dhcpServerConfig = {
      #   PoolOffset = 100;
      #   PoolSize = 20;
      #   EmitDNS = "yes";
      #   DNS = "8.8.8.8";
      # };
    };
    "40-wlp4s0" = {
      networkConfig = {
        IPv6AcceptRA = false;
        IPv6PrefixDelegation = "dhcpv6";
        IPv6DuplicateAddressDetection = 1;
        IPv6PrivacyExtensions = lib.mkForce "no";
        # DHCPServer = true; # ipv4, see dhcpServerConfig below. disabled in favour of dnsmasq.
      };
      ipv6PrefixDelegationConfig = {
        RouterLifetimeSec = 300; # required as otherwise no RA's are being emitted
      };
      # dhcpServerConfig = {
      #   PoolOffset = 100;
      #   PoolSize = 20;
      #   EmitDNS = "yes";
      #   DNS = "8.8.8.8";
      # };
    };
    "40-ppp0" = {
      name = "ppp0";
      networkConfig = {
        DHCP = "ipv6";
        IPv6AcceptRA = "yes";
        KeepConfiguration = "yes"; # accept config set by pppd
      };
      dhcpV6Config = {
        ForceDHCPv6PDOtherInformation = "yes";
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = true;
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

  # IPv6 prefix delegation is handled by systemd-networkd
  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      interface=wlp4s0,enp2s0,enp3s0
      bind-interfaces

      # don't send bogus requests out on the internets
      bogus-priv

      # printer net
      dhcp-range=enp2s0,192.168.2.10,192.168.2.150,12h

      # fixed ip for printer
      dhcp-host=enp2s0,00:1b:a9:f9:e3:41,192.168.2.2,12h

      # wifi
      dhcp-range=wlp4s0,192.168.123.10,192.168.123.150,12h

      # nuc1
      dhcp-range=enp3s0,192.168.124.10,192.168.124.150,12h

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

        # Login settings.
        name "${netcfg.dsl.username}"
        noauth
        hide-password

        # Connection settings.
        persist
        maxfail 0
        holdoff 5
 
        # LCP settings.
        lcp-echo-interval 10
        lcp-echo-failure 3
        
        # PPPoE compliant settings.
        noaccomp
        default-asyncmap
        mtu 1492

        # IP settings.
        noipdefault
        defaultroute
        +ipv6
        defaultroute6

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

  # compensate flaky ppp connection
  # systemd.services.reboot-daily = {
  #   description = "Reboot every morning";
  #   startAt = "*-*-* 03:30:00";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.systemd}/bin/systemctl --force reboot";
  #   };
  # };

  users.users = {
    wilko = {
      name = "wilko";
      isNormalUser = true;
      home = "/home/wilko";
      createHome = true;
      useDefaultShell = true;
      uid = 1001;
      description = "Wilko Volckens";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJMj7eNfwFmUF3bQmJazSzrMie7nMPze7DKpRZuMMRl wilkosthinkpad@DESKTOP-9RR661R"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # workaround AirPrint printer not showing up after boot
  systemd.services.avahi-daemon.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";

  programs.mosh.enable = true;
}
