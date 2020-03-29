{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/bs53lan.nix>
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
      };

      file = {};

      frontends = {
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
      };
      backends = {
        influxdb = {
          servers.s1.url = "http://localhost:18086";
        };
        kapacitor = {
          servers.s1.url = "http://localhost:19092";
        };
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
  ];

  ptsd.lego.extraDomains = [
    "grafana.services.nerdworks.de"
    "hass.services.nerdworks.de"
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
}
