with import <ptsd/lib>;
{ config, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/dokuwiki.nix>
    <ptsd/2configs/drone-exec-container.nix>
    <ptsd/2configs/grafana.nix>
    <ptsd/2configs/home-assistant.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/monica.nix>
    <ptsd/2configs/mosquitto.nix>
    <ptsd/2configs/nextcloud.nix>
    <ptsd/2configs/nextcloud-vsftpd-scans.nix>
    #<ptsd/2configs/nwalerta.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/nwoctoprint.nix>
    <ptsd/2configs/postgresql.nix>
    <ptsd/2configs/prometheus/server.nix>
    <ptsd/2configs/prometheus/node.nix>

    <secrets-shared/nwsecrets.nix>

    <client-secrets/dbk/vdi.nix>
    <ptsd/2configs/xrdp.nix>

    <ptsd/2configs/zsh-enable.nix>

    <home-manager/nixos>
  ];

  ptsd.nobbofin-autofetch.enable = true;

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  networking = {
    hostName = "nas1";
    useNetworkd = true;
    useDHCP = false;

    # Bridge is used for Nextcloud-Syncthing-Containers
    bridges.br0.interfaces = [ "eno1" ];
    interfaces.br0.useDHCP = true;


    firewall.interfaces = {
      br0 = {
        allowedTCPPorts = [ 631 ];
        allowedUDPPorts = [ 631 ];
      };
      nwvpn.allowedTCPPorts = [ 12345 ]; # fpv folder share
    };
  };

  systemd.network = {
    netdevs = {
      "40-ff" = {
        netdevConfig = {
          Name = "ff";
          Kind = "bridge";
        };
      };
    };
    networks = {
      "40-ff" = {
        matchConfig.Name = "ff";
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };
    };
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:eno1:off" ];

  # route traffic from/to nwvpn
  ptsd.wireguard = {
    enableGlobalForwarding = true;
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "tank";
  };

  ptsd.vdi-container = {
    enable = true;
    extIf = "br0";
  };

  ptsd.samba-sonos = {
    enable = true;
    mediaPath = "/tank/enc/media";
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginx.override {
      modules = with pkgs.nginxModules; [ fancyindex ];
    };
    commonHttpConfig = ''
      charset UTF-8;
      types_hash_max_size 4096;
      server_names_hash_bucket_size 128;
    '';
    virtualHosts = {
      "www.nerdworks.de" = {
        listen = [
          {
            addr = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
            port = 12345; # fpv folder share
          }
        ];
        locations."/" = {
          alias = "/tank/enc/public-www/";
          extraConfig = ''
            fancyindex on;
            fancyindex_exact_size off;
          '';
        };
      };
    };
  };

  ptsd.nwtraefik = {
    enable = true;
    entryPoints = {
      "lan-http" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}:80";
        http.redirections.entryPoint = {
          to = "lan-https";
          scheme = "https";
          permanent = true;
        };
      };
      "lan-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}:443";
      };
      "nwvpn-http" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:80";
        http.redirections.entryPoint = {
          to = "nwvpn-https";
          scheme = "https";
          permanent = true;
        };
      };
      "nwvpn-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:443";
      };

      # added for local tls monitoring
      "loopback6-https".address = "[::1]:443";
    };
    certificates =
      let
        crt = domain: {
          certFile = "/var/lib/acme/${domain}/cert.pem";
          keyFile = "/var/lib/acme/${domain}/key.pem";
        };
      in
      [
        (crt "nas1.lan.nerdworks.de")
        (crt "wiki.services.nerdworks.de")
        (crt "influxdb.services.nerdworks.de")
        (crt "grafana.services.nerdworks.de")
        (crt "hass.services.nerdworks.de")
        (crt "monica.services.nerdworks.de")
        (crt "nextcloud.services.nerdworks.de")
        (crt "octoprint.services.nerdworks.de")
      ];
  };

  security.acme = {
    certs =
      let
        envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
          ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
          ACME_DNS_API_BASE=https://auth.nerdworks.de
        '';
      in
      {
        "wiki.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "wiki.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "influxdb.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "influxdb.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "grafana.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "grafana.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "hass.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "hass.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "monica.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "monica.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "nextcloud.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "nextcloud.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "octoprint.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "octoprint.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };
      };
  };

  ptsd.cups-airprint = {
    enable = true;
    printerName = "MFC7440N";
    listenAddress = "${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}:631";
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
      qemuRunAsRoot = false;
    };
  };

  containers.ff = {
    autoStart = false;
    hostBridge = "ff";
    privateNetwork = true;
    bindMounts = {
      "/tank/enc/roms" = {
        hostPath = "/tank/enc/roms";
        isReadOnly = false;
      };
    };

    config =
      { config, pkgs, ... }:
      {
        imports = [
          <ptsd>
          <ptsd/2configs>
        ];

        boot.isContainer = true;

        networking = {
          useHostResolvConf = false;
          useNetworkd = true;
          interfaces.eth0.useDHCP = true;
        };

        time.timeZone = "Europe/Berlin";

        i18n = {
          defaultLocale = "de_DE.UTF-8";
          supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
        };

        environment.systemPackages = with pkgs; [ tmux rtorrent ];
      };
  };

}
