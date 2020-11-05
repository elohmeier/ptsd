{ config, lib, pkgs, ... }:

with lib;
let
  universe = import <ptsd/2configs/universe.nix>;

  domain = "nextcloud.services.nerdworks.de";
  nextcloudUid = 131; # unused as of 19.09, old docker uid

  generateSyncthingContainer = name: values: nameValuePair "st-${name}" {
    autoStart = true;
    hostBridge = "br0";
    privateNetwork = true;
    bindMounts = {
      "/run/keys" = {
        hostPath = "/run/keys";
        isReadOnly = true;
      };
      "/var/lib/nextcloud/data/${name}" = {
        hostPath = "/var/lib/nextcloud/data/${name}";
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
          nameservers = [ "8.8.8.8" "8.8.4.4" ];
          useNetworkd = true;
          interfaces.eth0.useDHCP = true;
        };

        time.timeZone = "Europe/Berlin";

        i18n = {
          defaultLocale = "de_DE.UTF-8";
          supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
        };

        users.groups.nginx = { gid = config.ids.gids.nginx; };
        users.users.nextcloud = {
          uid = nextcloudUid;
          isSystemUser = true;
        };

        services.syncthing = {
          enable = true;

          # mirror the nextcloud permissions
          user = "nextcloud";
          group = "nginx";

          declarative = {
            key = "/run/keys/syncthing-${name}.key";
            cert = "/run/keys/syncthing-${name}.crt";
            devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);
            folders = values.folders;
          };
        };
      };
  };
in
{
  services.postgresql.ensureDatabases = [ "nextcloud" ];
  services.postgresql.ensureUsers = [
    {
      name = "nextcloud";
      ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
    }
  ];

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  ptsd.secrets.files."ncadmin-pw" = { };

  # this is not set inside nixpkgs for NextCloud as of 19.09
  users.users.nextcloud = {
    isSystemUser = true;
    uid = nextcloudUid;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud19;
    hostName = domain;
    https = true;
    caching = {
      apcu = true;
      redis = true;
      memcached = false;
    };
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminuser = "ncadmin";
      adminpassFile = config.ptsd.secrets.files."ncadmin-pw".path;
      trustedProxies = [ "127.0.0.1" ];
    };
  };

  services.nginx.virtualHosts."${domain}".listen = [
    {
      addr = "127.0.0.1";
      port = config.ptsd.nwtraefik.ports.nextcloud;
    }
  ];

  services.redis = {
    enable = true; # remember to activate it in the local NextCloud config file!
  };

  systemd.services.nextcloud-reindex-syncthing-folders = {
    description = "Update the NextCloud index for folders managed by Syncthing";
    wants = [ "network.target" "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    startAt = "daily";

    script = ''
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=luisa/files
    '';

    # wait for 20.03, sudo is optional there
    #serviceConfig = {
    #  User = "nextcloud";
    #};
  };

  ptsd.nwtraefik = {
    middlewares."nextcloud-redirectregex" =
      {
        redirectRegex = {
          permanent = true;
          regex = "https://(.*)/.well-known/(card|cal)dav";
          replacement = ''https://''${1}/remote.php/dav/'';
        };
      };

    services = [
      {
        name = "nextcloud";
        rule = "Host(`${domain}`)";
        extraMiddlewares = [ "nextcloud-redirectregex" ];
      }
    ];
  };

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" ];
      }
      {
        urls = [ "https://${domain}/login" ];
        response_string_match = "a safe home for all your data";
      }
    ];
    x509_cert = [
      {
        sources = [
          "https://${domain}:443"
        ];
      }
    ];
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check host ${domain} with address ${domain}
        if failed
          port 443
          protocol https request "/login" and certificate valid > 30 days          
          content = "a safe home for all your data"
        then alert
    ''
  ];

  ptsd.secrets.files = {
    "syncthing-enno.key" = { };
    "syncthing-enno.crt" = { };
    "syncthing-luisa.key" = { };
    "syncthing-luisa.crt" = { };
  };

  containers = mapAttrs' generateSyncthingContainer {

    # device-id enno: 2U7PBTB-3AVWHDO-KKITN5S-JW5AKLX-2MLBQOR-PJDL2QH-BZZJBMD-DFX3MQI
    "enno" =
      let
        root = "/var/lib/nextcloud/data/enno/files";
      in
      {
        folders = {
          "${root}/FPV" = {
            id = "xxdwi-yom6n";
            devices = [ "tp1" "ws1" "ws1-win10n" ];
          };
          "${root}/Hörspiele" = {
            id = "rqnvn-lmhcm";
            devices = [ "ext-arvid" "tp1" ];
            type = "receiveonly";
          };
          "${root}/Pocket" = {
            id = "hmekh-kgprn";
            devices = [ "nuc1" "tp1" "ws1" ];
          };
          "${root}/LuNo" = {
            id = "3ull9-9deg4";
            devices = [ "mb1" "tp1" "tp2" "ws1" ];
          };
          "${root}/Scans" = {
            id = "ezjwj-xgnhe";
            devices = [ "tp1" "ws1" ];
          };
          "${root}/Templates" = {
            id = "gnwqu-yt7qc";
            devices = [ "nuc1" "tp1" "ws1" ];
          };
          "${root}/repos-ws1" = {
            id = "jihdi-qxmi3";
            devices = [ "tp1" "ws1" ];
          };
        };
      };

    # device-id luisa: HGJGPWK-AZ7W6YP-42W6HGC-4OD3U33-GQZJ6N3-24YL7V2-CB26CIJ-DT5RXAW
    "luisa" =
      let
        root = "/var/lib/nextcloud/data/luisa/files";
      in
      {
        folders = {
          "${root}/LuNo" = {
            id = "3ull9-9deg4";
            devices = [ "tp1" "tp2" "mb1" "ws1" ];
          };
          "${root}/Bilder" = {
            id = "ugmai-ti6vl";
            devices = [ "tp2" "mb1" ];
          };
          "${root}/Dokumente" = {
            id = "sqkfd-m9he7";
            devices = [ "tp2" "mb1" ];
          };
          "${root}/Musik" = {
            id = "zvffu-ff92z";
            devices = [ "tp2" "mb1" ];
          };
          "${root}/Scans" = {
            id = "dnryo-kz7io";
            devices = [ "tp2" "mb1" "ws1" ];
          };
        };
      };

  };

}
