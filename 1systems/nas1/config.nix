{ config, lib, pkgs, ... }:
with lib;
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/hardened.nix
    ../../2configs/printers/mfc7440n.nix
    ../../2configs/nwhost.nix
    # TODO: fix tmp folder error
    # TODO: activate prometheus http monitoring
    ../../2configs/prometheus/node.nix

    ../../2configs/users/enno.nix # for git repo support

    ./modules/backup.nix
    ./modules/fraam-gdrive-backup.nix
    ./modules/grafana.nix
    ./modules/home-assistant.nix
    ./modules/icloudpd.nix
    ./modules/loki.nix
    ./modules/octoprint.nix
    ./modules/postgresql.nix
    ./modules/prometheus
    ./modules/syncthing.nix
    ./modules/vsftpd.nix
  ];

  ptsd.fluent-bit = {
    enable = true;
  };

  ptsd.tailscale.ip = "100.101.207.64";
  ptsd.tailscale.cert.enable = true;

  ptsd.nwbackup.enable = false;

  ptsd.photoprism = {
    enable = true;
    httpHost = "191.18.19.37";
    httpPort = 2342;
    siteUrl = "https://fotos.nerdworks.de/";
    photosDirectory = "/tank/enc/rawphotos/photos";
  };

  ptsd.monica = {
    enable = true;
    domain = "monica.services.nerdworks.de";
    entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
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
        allowedTCPPorts = [
          631 # cups
          448 # traefik/gitweb
          22000 # syncthing
        ];
        allowedUDPPorts = [ 631 ];
      };
      nwvpn.allowedTCPPorts = [
        12345 # fpv folder share
        448 # traefik/gitweb
        2342 # photoprism
      ];
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

  # for git-http-backend
  services.fcgiwrap.enable = true;

  services.gitweb.extraConfig = ''
    # stylesheet to use
    @stylesheets = ("/git/static/gitweb.css");

    # javascript code for gitweb
    $javascript = "/git/static/gitweb.js";

    # logo to use
    $logo = "/git/static/git-logo.png";
  '';

  services.nginx = {
    enable = true;
    serverNamesHashBucketSize = 128;
    gitweb = {
      enable = true;
      location = "/git";
      virtualHost = "nas1.host.nerdworks.de";
    };
    commonHttpConfig = ''
      charset UTF-8;
      port_in_redirect off;
    '';
    virtualHosts = {
      "nas1.host.nerdworks.de" = {
        listen = [{ addr = "127.0.0.1"; port = config.ptsd.ports.gitweb; }];

        # as in https://fishilico.github.io/generic-config/etc-server/web/gitweb.html#nginx-configuration
        locations = {
          "~ ^/git/.*\\.git/objects/([0-9a-f]+/[0-9a-f]+|pack/pack-[0-9a-f]+.(pack|idx))$" = {
            root = "/srv/git";
          };

          "~ ^/(.*\\.git/(HEAD|info/refs|objects/info/.*|git-upload-pack))$" = {
            extraConfig = ''
              rewrite ^/git(/.*)$ $1 break;
              fastcgi_pass unix:/run/fcgiwrap.sock;
              fastcgi_param SCRIPT_FILENAME     ${pkgs.git}/bin/git-http-backend;
              fastcgi_param PATH_INFO           $uri;
              fastcgi_param GIT_PROJECT_ROOT    /srv/git;
              fastcgi_param GIT_HTTP_EXPORT_ALL "";
              include ${pkgs.nginx}/conf/fastcgi_params;
            '';
          };
        };
      };
    };
  };

  ptsd.nwtraefik = {
    enable = true;
    services = [
      {
        name = "gitweb";
        entryPoints = [ "nwvpn-gitweb-https" ];
        rule = "Host(`nas1.host.nerdworks.de`)";
      }
    ];
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
      "nwvpn-gitweb-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:448";
      };

      # added for local tls monitoring & alertmanager
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
        #(crt "nas1.lan.nerdworks.de")
        (crt "alerts.services.nerdworks.de")
        (crt "grafana.services.nerdworks.de")
        (crt "hass.services.nerdworks.de")
        (crt "monica.services.nerdworks.de")
        (crt "prometheus.services.nerdworks.de")
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
        "alerts.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "alerts.services.nerdworks.de";
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

        "prometheus.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "prometheus.services.nerdworks.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };
      };
  };

  services.printing = {
    enable = true;
    browsing = true;
    defaultShared = true;
    allowFrom = [ "all" ];
    listenAddresses = [ "*:631" ];
    extraConf = ''
      ServerAlias *
      DefaultLanguage de
      DefaultPaperSize A4
      ReadyPaperSizes A4
      BrowseLocalProtocols dnssd
    '';
  };

  networking.firewall.trustedInterfaces = [ "br0" ];

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
    nssmdns = true;
  };

  ptsd.navidrome = {
    enable = true;
    musicFolder = "/tank/enc/media";
  };

  ptsd.nwlogrotate.config = ''
    /var/spool/nginx/access.log {
      daily
      rotate 7
      missingok
      notifempty
      compress
      dateext
      dateformat .%Y-%m-%d
      postrotate
        systemctl kill -s USR1 nginx.service
      endscript
    }
  '';

  # compensate flaky airprint service
  systemd.services.restart-cups = {
    description = "Restart cups every morning";
    startAt = "*-*-* 03:30:00";
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemctl restart cups.service";
    };
  };

  systemd.services.prometheus-check_ssl_cert = {
    description = "monitor ssl/tlsa/dane for nerdworks.de mail";
    environment = {
      # use google dns for TLSA lookup
      HOME = pkgs.writeTextFile {
        name = "digrc";
        text = "@8.8.8.8";
        destination = "/.digrc";
      };
    };
    path = with pkgs; [
      # checkSSLCert deps
      dig
      gawk
      glibc
      nettools

      bash
      checkSSLCert
      moreutils # sponge
    ];
    script = ''
      ${../../4scripts/prometheus-check_ssl_cert.sh} | sponge /var/log/prometheus-check_ssl_cert.prom
    '';
    startAt = "*:0/15"; # every 15 mins
  };
}
