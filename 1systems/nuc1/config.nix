{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/cli-tools.nix>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/home-assistant.nix>
      <ptsd/2configs/monica.nix>
      <ptsd/2configs/mosquitto.nix>
      #<ptsd/2configs/nextcloud.nix>
      <ptsd/2configs/postgresql.nix>
      <ptsd/2configs/samba.nix>
      <ptsd/2configs/vsftpd.nix>
      <secrets-shared/nwsecrets.nix>
    ];

  users.users.media = {
    name = "media";
    isSystemUser = true;
    home = "/mnt/int/media";
    createHome = false;
    useDefaultShell = true;
    uid = 1001;
    description = "Media User";
    extraGroups = [];
  };

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "nw27";
  };

  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;

  #   # mirror the nextcloud permissions
  #   user = "nextcloud";
  #   group = "nginx";
  # };

  ptsd.nwtelegraf = {
    extraConfig = {
      inputs.influxdb = {
        urls = [
          "https://${config.networking.hostName}.${config.networking.domain}:8086/debug/vars"
        ];
      };
      inputs.http = [
        {
          name_override = "email";
          urls = [ "http://127.0.0.1:8000/mail" ];
          data_format = "json";
          tag_keys = [ "account" "folder" ];
        }
        {
          name_override = "todoist";
          urls = [ "http://127.0.0.1:8000/todoist" ];
          data_format = "json";
          tag_keys = [ "project" ];
        }
        {
          name_override = "nobbofin";
          urls = [ "http://127.0.0.1:8000/nobbofin" ];
          data_format = "json";
        }
      ];
      inputs.x509_cert = [
        {
          sources = [
            "https://${config.networking.hostName}.${config.networking.domain}:443"
          ];
        }
      ];
    };
  };

  services.nwstats = {
    enable = true;
  };

  # intweb
  # services.nginx = {
  #   enable = true;

  #   commonHttpConfig = ''
  #     charset UTF-8;
  #   '';

  #   package =
  #     pkgs.nginx.override { modules = with pkgs.nginxModules; [ fancyindex ]; };

  #   virtualHosts = {

  # "alerta.services.nerdworks.de" = {
  #   listen = [
  #     {
  #       addr = "127.0.0.1";
  #       port = 1081;
  #     }
  #   ];
  #   locations."/" = let
  #     alertaCfg = pkgs.symlinkJoin {
  #       name = "alerta-webui-cfg";
  #       paths = [
  #         pkgs.alerta-webui
  #         (
  #           pkgs.writeTextFile {
  #             name = "alerta-webui-config.json";
  #             destination = "/config.json";
  #             text = ''
  #               {"endpoint": "https://nuc1.host.nerdworks.de:5000"}
  #             '';
  #           }
  #         )
  #       ];
  #     };
  #   in
  #     {
  #       root = "${alertaCfg}";
  #       extraConfig = ''
  #         try_files $uri $uri/ /index.html;
  #       '';
  #     };
  # };

  # "intweb.services.nerdworks.de" = {
  #   listen = [
  #     {
  #       addr = "127.0.0.1";
  #       port = 1080;
  #     }
  #   ];
  #   locations."/" = {
  #     root = "/mnt/int";
  #     extraConfig = ''
  #       fancyindex on;              # Enable fancy indexes.
  #       fancyindex_exact_size off;  # Output human-readable file sizes.
  #     '';
  #   };

  #   locations."/sync" = {
  #     root = "/mnt/int";
  #     extraConfig = ''
  #       fancyindex on;              # Enable fancy indexes.
  #       fancyindex_exact_size off;  # Output human-readable file sizes.
  #       auth_basic           "Privater Bereich";
  #       auth_basic_user_file ${<secrets/intweb.htpasswd>};
  #     '';
  #   };
  #   locations."/privat" = {
  #     root = "/mnt/int";
  #     extraConfig = ''
  #       fancyindex on;              # Enable fancy indexes.
  #       fancyindex_exact_size off;  # Output human-readable file sizes.
  #       auth_basic           "Privater Bereich";
  #       auth_basic_user_file ${<secrets/intweb.htpasswd>};
  #     '';
  #   };
  # };
  #   };
  # };

  services.influxdb = {
    enable = true;
    extraConfig = {
      http = {
        auth-enabled = true;
        bind-address = "127.0.0.1:18086";
      };
    };
  };

  services.kapacitor = let
    kapacitorSecrets = import <secrets/kapacitor.nix>;
  in
    {
      enable = true;
      port = 19092;
      bind = "127.0.0.1";
      defaultDatabase = {
        enable = true;
        url = "https://nuc1.host.nerdworks.de:8086";
        username = "kapacitor";
        password = kapacitorSecrets.influxPassword;
      };
    };

  environment.variables = {
    KAPACITOR_URL = "https://nuc1.host.nerdworks.de:9092";
  };

  systemd.services.kapacitor = {
    after = [ "influxdb" ];
    wants = [ "influxdb" ];
  };

  # ptsd.alerta = let
  #   alertaSecrets = import <secrets/alerta.nix>;
  #   py3 = pkgs.python3.override {
  #     packageOverrides = self: super: {
  #       alerta-server = super.callPackage ../../5pkgs/alerta-server {};
  #       sentry-sdk = super.callPackage ../../5pkgs/sentry-sdk {};
  #       psycopg2 = super.psycopg2.override {
  #         postgresql = pkgs.postgresql_11;
  #       };
  #     };
  #   };
  # in
  #   {
  #     enable = true;
  #     port = 15000;
  #     bind = "127.0.0.1";
  #     databaseUrl = "postgresql://alerta:${alertaSecrets.dbPassword}@nuc1.host.nerdworks.de/alerta";
  #     databaseName = "alerta";
  #     corsOrigins = [ "https://nuc1.host.nerdworks.de:5000" "https://nuc1.host.nerdworks.de:5001" ];
  #     serverPackage = py3.pkgs.alerta-server;
  #     clientPackage = py3.pkgs.alerta;
  #     extraConfig = ''
  #       ADMIN_USERS = ['enno']
  #     '';
  #   };

  services.grafana = let
    grafanaSecrets = import <secrets/grafana.nix>;
  in
    {
      enable = true;
      rootUrl = "https://grafana.services.nerdworks.de/";
      security = {
        adminUser = grafanaSecrets.adminUser;
        adminPassword = grafanaSecrets.adminPassword;
      };
      provision = {
        enable = true;
        datasources = [
          {
            name = "InfluxDB Telegraf";
            type = "influxdb";
            isDefault = true;
            database = "telegraf";
            user = "grafana";
            password = grafanaSecrets.influxPassword;
            url = "https://${config.networking.hostName}.${config.networking.domain}:8086";
          }
        ];
      };
    };

  services.traefik = {
    enable = true;
    group = "docker";
    configOptions = {
      logLevel = "ERROR";
      accessLog = {
        filePath = "/var/lib/traefik/access.log";
        bufferingSize = 100;
      };
      defaultEntryPoints = [ "https" "http" ];
      entryPoints = {
        http = {
          address = ":80";
          redirect.entryPoint = "https";
        };
        https = {
          address = ":443";
          tls = {
            certificates = [
              {
                certFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
                keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
              }
            ];
          };
        };
        https_influxdb = {
          address = ":8086";
          tls = {
            certificates = [
              {
                certFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
                keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
              }
            ];
          };
        };
        https_kapacitor = {
          address = ":9092";
          tls = {
            certificates = [
              {
                certFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
                keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
              }
            ];
          };
        };
        # https_alerta = {
        #   address = ":5000";
        #   tls = {
        #     certificates = [
        #       {
        #         certFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
        #         keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
        #       }
        #     ];
        #   };
        # };
        # https_alerta_webui = {
        #   address = ":5001";
        #   tls = {
        #     certificates = [
        #       {
        #         certFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
        #         keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
        #       }
        #     ];
        #   };
        # };
      };

      file = {};

      frontends = {
        # intweb = {
        #   entryPoints = [ "https" "http" ];
        #   backend = "nginx_intweb";
        #   routes.r1.rule = "Host:intweb.services.nerdworks.de";
        #   passHostHeader = true;
        # };
        influxdb = {
          entryPoints = [ "https_influxdb" ];
          backend = "influxdb";
          routes.r1.rule = "Host:${config.networking.hostName}.${config.networking.domain}";
          passHostHeader = true;
        };
        kapacitor = {
          entryPoints = [ "https_kapacitor" ];
          backend = "kapacitor";
          routes.r1.rule = "Host:${config.networking.hostName}.${config.networking.domain}";
          passHostHeader = true;
        };
        # alerta = {
        #   entryPoints = [ "https_alerta" ];
        #   backend = "alerta";
        #   routes.r1.rule = "Host:${config.networking.hostName}.${config.networking.domain}";
        #   passHostHeader = true;
        # };
        # alerta_webui = {
        #   entryPoints = [ "https_alerta_webui" ];
        #   backend = "nginx_alerta_webui";
        #   routes.r1.rule = "Host:${config.networking.hostName}.${config.networking.domain}";
        #   passHostHeader = true;
        # };
        grafana = {
          entryPoints = [ "https" "http" ];
          backend = "grafana";
          routes.r1.rule = "Host:grafana.services.nerdworks.de";
          passHostHeader = true;
        };
        hass = {
          entryPoints = [ "https" "http" ];
          backend = "hass";
          routes.r1.rule = "Host:hass.services.nerdworks.de";
          passHostHeader = true;
        };
        # nextcloud = {
        #   entryPoints = [ "https" "http" ];
        #   backend = "nginx_nextcloud";
        #   routes.r1.rule = "Host:nextcloud.services.nerdworks.de";
        #   passHostHeader = true;
        # };
      };
      backends = {
        # nginx_intweb = {
        #   servers.s1.url = "http://localhost:1080";
        # };
        # nginx_alerta_webui = {
        #   servers.s1.url = "http://localhost:1081";
        # };
        # nginx_nextcloud = {
        #   servers.s1.url = "http://localhost:1082";
        # };
        influxdb = {
          servers.s1.url = "http://localhost:18086";
        };
        kapacitor = {
          servers.s1.url = "http://localhost:19092";
        };
        # alerta = {
        #   servers.s1.url = "http://localhost:15000";
        # };
        grafana = {
          servers.s1.url = "http://localhost:3000";
        };
        hass = {
          servers.s1.url = "http://localhost:8123";
        };
      };
      docker = {
        endpoint = "unix:///var/run/docker.sock";
        watch = true;
        exposedbydefault = false;
      };
    };
  };

  users.groups.lego = {
    members = [ "traefik" ];
  };

  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
    5432 # postgresql
    8086 # InfluxDB
    9092 # Kapacitor
    # 5000 # Alerta
    # 5001 # Alerta Web-UI
  ];

  ptsd.lego.extraDomains = [
    "grafana.services.nerdworks.de"
    "hass.services.nerdworks.de"
    "intweb.services.nerdworks.de" # unused
  ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    hostName = "nuc1";
    interfaces.eth0.useDHCP = true;
  };

  boot.kernelParams = [ "ip=192.168.178.10::192.168.178.1:255.255.255.0:${config.networking.hostName}:eth0:off" ];

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostECDSAKey = toString <secrets> + "/initrd-ssh-key";
    };
    postCommands = ''
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };

  ptsd.nwbackup.paths = [ "/mnt/int" ];

  # virtualisation.libvirtd.enable = true;
}
