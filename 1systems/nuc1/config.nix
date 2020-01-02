{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/backup-host.nix>
      <ptsd/2configs/home-assistant.nix>
      <ptsd/2configs/mosquitto.nix>
      <ptsd/2configs/postgresql.nix>
      <ptsd/2configs/samba.nix>
      <ptsd/2configs/vsftpd.nix>
      <secrets-shared/nwsecrets.nix>
    ];

  users.users.media = {
    name = "media";
    isNormalUser = true;
    home = "/mnt/int/media";
    createHome = false;
    useDefaultShell = true;
    uid = 1001;
    description = "Media User";
    extraGroups = [];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
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
    };
  };

  services.nwstats = {
    enable = true;
  };

  services.nwmonica = let
    monicaSecrets = import <secrets/monica.nix>;
  in
    {
      enable = true;
      appKey = monicaSecrets.appKey;
      dbPassword = monicaSecrets.dbPassword;
      hashSalt = monicaSecrets.hashSalt;
      mailPassword = monicaSecrets.mailPassword;
    };

  # intweb
  services.nginx = {
    enable = true;

    commonHttpConfig = ''
      charset UTF-8;
    '';

    package =
      pkgs.nginx.override { modules = with pkgs.nginxModules; [ fancyindex ]; };

    virtualHosts = {

      "intweb.services.nerdworks.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 1080;
          }
        ];
        locations."/" = {
          root = "/mnt/int";
          extraConfig = ''
            fancyindex on;              # Enable fancy indexes.
            fancyindex_exact_size off;  # Output human-readable file sizes.
          '';
        };

        locations."/sync" = {
          root = "/mnt/int";
          extraConfig = ''
            fancyindex on;              # Enable fancy indexes.
            fancyindex_exact_size off;  # Output human-readable file sizes.
            auth_basic           "Privater Bereich";
            auth_basic_user_file ${<secrets/intweb.htpasswd>};
          '';
        };
        locations."/privat" = {
          root = "/mnt/int";
          extraConfig = ''
            fancyindex on;              # Enable fancy indexes.
            fancyindex_exact_size off;  # Output human-readable file sizes.
            auth_basic           "Privater Bereich";
            auth_basic_user_file ${<secrets/intweb.htpasswd>};
          '';
        };
      };
    };
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
      };

      file = {};

      frontends = {
        intweb = {
          entryPoints = [ "https" "http" ];
          backend = "nginx";
          routes.r1.rule = "Host:intweb.services.nerdworks.de";
          passHostHeader = true;
        };
        influxdb = {
          entryPoints = [ "https_influxdb" ];
          backend = "influxdb";
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
        nginx = {
          servers.s1.url = "http://localhost:1080";
        };
        influxdb = {
          servers.s1.url = "http://localhost:18086";
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
    5432
    8086 # InfluxDB
  ];

  ptsd.lego.extraDomains = [
    "grafana.services.nerdworks.de"
    "hass.services.nerdworks.de"
    "intweb.services.nerdworks.de"
    "monica.services.nerdworks.de"
  ];

  networking.hostName = "nuc1";

  boot.kernelParams = [ "ip=192.168.178.10::192.168.178.1:255.255.255.0:${config.networking.hostName}:eth0:off" ];

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostECDSAKey = "/var/src/secrets/initrd-ssh-key";
    };
    postCommands = ''
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };

  ptsd.nwbackup.paths = [ "/mnt/int" ];

  virtualisation.libvirtd.enable = true;
}
