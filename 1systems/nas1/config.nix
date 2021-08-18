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
    ./modules/nextcloud.nix
    ./modules/nextcloud-vsftpd-scans.nix
    ./modules/nwoctoprint.nix
    ./modules/postgresql.nix
    ./modules/prometheus/server.nix
    ./modules/syncthing.nix
  ];

  ptsd.nwbackup.enable = false;

  ptsd.photoprism = {
    enable = true;
    httpHost = "191.18.19.37";
    httpPort = 2342;
    siteUrl = "https://fotos.nerdworks.de/";
    photosDirectory = "/tank/enc/rawphotos/photos";
    user = "nextcloud";
    group = "nginx";
  };

  ptsd.monica = {
    enable = true;
    domain = "monica.services.nerdworks.de";
    entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
  };

  users.groups.photosync-enno = { };
  users.users.photosync-enno = {
    group = "photosync-enno";
    isNormalUser = true;
    home = "/tank/enc/photosync/enno";
    createHome = false;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6244nhNjYfVoqSoPk8JKDbrok6YnmDvueWzEc30ftYkTHlZND/xXTJ0kLvTQm5s0NB1Mw1o8VRwFTDJC6Y1a1xkz+O/JI5QV33jOjezGCytwZMYo3Phh4k77MtM3/uKLNC2eKVZKp0DuOekfmH2eSfbHSB+TeFcxDtPTn789cYNUS4tH/sY+iyRFwgO3NekyKEskcUhYLQg/fUTWQ1xKHqhTD4Ns2FmOxkGixvfkWbVqEf/BZflTDsBSCSTidHB0Xyo5CfOsYvJyY8WYugAd36zgU+eO5poeM7jZi0pBqltCajEaCkTaCaOL8R7YuIw6eyH8BywcOGjf/VRJgw/59IGf01k9nPqTa2L2IsX9IAOLDgzZaNXKuk0brW5nNflunzJknB6DdA9eQPqnfNGxdY515NqHjkEFN2olax7Ipbp0AJWEYeKvhQ7Tt2egE7fQYZoZzs8+OQkeQ1JkzYX2ipD7X81tPVyR4d/2e1YMt0rGuuHAkKLVesjWuEsx8kw5AFwiRhGb0XeuM6gpSTczRoQ8W4NsxbSMwg74gxqs81iLJPxHqBUM8/8krTQ48fMuYfxdveEFO48Yts3iRkZL/N4FBUY+GLSQndTK8iRnall7qv/kkFMVgkXyLE11sieo9aSVWoeAYEvrtYu/5J0yurvuftUqw4F6SH983sZaO3w== photosync@iph3"
    ];
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

  ptsd.samba-sonos = {
    enable = true;
    mediaPath = "/tank/enc/media";
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
    gitweb = {
      enable = true;
      location = "/git";
      virtualHost = "nas1.host.nerdworks.de";
    };
    # package = pkgs.nginx.override {
    #   modules = with pkgs.nginxModules; [ fancyindex ];
    # };
    commonHttpConfig = ''
      charset UTF-8;
      types_hash_max_size 4096;
      server_names_hash_bucket_size 128;
      port_in_redirect off;
    '';
    virtualHosts = {
      "nas1.host.nerdworks.de" = {
        listen = [{ addr = "127.0.0.1"; port = config.ptsd.nwtraefik.ports.gitweb; }];

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
      # "www.nerdworks.de" = {
      #   listen = [
      #     {
      #       addr = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
      #       port = 12345; # fpv folder share
      #     }
      #   ];
      #   locations."/" = {
      #     alias = "/tank/enc/public-www/";
      #     extraConfig = ''
      #       fancyindex on;
      #       fancyindex_exact_size off;
      #     '';
      #   };
      # };
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
        (crt "nextcloud.services.nerdworks.de")
        (crt "octoprint.services.nerdworks.de")
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

        "prometheus.services.nerdworks.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "prometheus.services.nerdworks.de";
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

  # virtualisation = {
  #   libvirtd = {
  #     enable = true;
  #     qemuPackage = pkgs.qemu_kvm;
  #     qemuRunAsRoot = false;
  #   };
  # };

  # containers.ff = {
  #   autoStart = false;
  #   hostBridge = "ff";
  #   privateNetwork = true;
  #   bindMounts = {
  #     "/tank/enc/roms" = {
  #       hostPath = "/tank/enc/roms";
  #       isReadOnly = false;
  #     };
  #   };

  #   config =
  #     { config, pkgs, inputs, ... }:
  #     {
  #       imports = [
  #         ../..
  #         ../../2configs
  #       ];

  #       boot.isContainer = true;

  #       networking = {
  #         useHostResolvConf = false;
  #         useNetworkd = true;
  #         interfaces.eth0.useDHCP = true;
  #       };

  #       time.timeZone = "Europe/Berlin";

  #       i18n = {
  #         defaultLocale = "de_DE.UTF-8";
  #         supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
  #       };

  #       environment.systemPackages = with pkgs; [ tmux rtorrent ];
  #     };
  # };

  # systemd.nspawn = {
  #   mydebian = {
  #     execConfig = {
  #       Hostname = "mydebian";
  #       PrivateUsers = false;
  #     };
  #     networkConfig = {
  #       Bridge = "br0";
  #     };
  #   };
  # };

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

  # ptsd.loki = {
  #   enable = true;
  #   config = {
  #     # https://grafana.com/docs/loki/latest/configuration/examples/
  #     auth_enabled = false;
  #     server.http_listen_port = 3100;
  #   };
  # };

  boot.supportedFilesystems = [ "exfat" ]; # canon sd card
}
