{ config, lib, pkgs, ... }:

with lib;

let
  universe = import <ptsd/2configs/universe.nix>;

  domain = "nextcloud.services.nerdworks.de";
  nextcloudUid = 131; # unused as of 19.09, old docker uid

  generateSyncthingContainer = name: values: nameValuePair "st-${name}"
    {
      autoStart = true;
      hostBridge = "br0";
      privateNetwork = true;
      localAddress = values.localAddress;
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

  ptsd.secrets.files."ncadmin-pw" = {};

  # this is not set inside nixpkgs for NextCloud as of 19.09
  users.users.nextcloud = {
    isSystemUser = true;
    uid = nextcloudUid;
  };

  services.nextcloud = {
    enable = true;
    hostName = domain;
    https = true;
    nginx.enable = true;
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

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "nextcloud";
      rule = "Host:${domain}";
    }
  ];

  ptsd.nwmonit.extraConfig = [
    ''
      check host ${domain} with address ${domain}
        if failed
          port 80
          protocol http
          status = 302
        then alert

        if failed
          port 443
          protocol https request "/login" and certificate valid > 30 days          
          content = "a safe home for all your data"
        then alert
    ''
  ];

  ptsd.secrets.files = {
    "syncthing-enno.key" = {};
    "syncthing-enno.crt" = {};
    "syncthing-luisa.key" = {};
    "syncthing-luisa.crt" = {};
  };

  containers = mapAttrs' generateSyncthingContainer {

    # device-id enno: 2U7PBTB-3AVWHDO-KKITN5S-JW5AKLX-2MLBQOR-PJDL2QH-BZZJBMD-DFX3MQI
    "enno" = let
      root = "/var/lib/nextcloud/data/enno/files";
    in
      {
        localAddress = "192.168.178.233/24";
        folders = {
          "${root}/Pocket" = {
            id = "hmekh-kgprn";
            devices = [ "ws1" ];
          };
          "${root}/LuNo" = {
            id = "3ull9-9deg4";
            devices = [ "ws1" ];
          };
        };
      };

    # device-id luisa: HGJGPWK-AZ7W6YP-42W6HGC-4OD3U33-GQZJ6N3-24YL7V2-CB26CIJ-DT5RXAW
    "luisa" = let
      root = "/var/lib/nextcloud/data/luisa/files";
    in
      {
        localAddress = "192.168.178.234/24";
        folders = {
          "${root}/LuNo" = {
            id = "3ull9-9deg4";
            devices = [ "ws1" ];
          };

          "${root}/Bilder" = {
            id = "ugmai-ti6vl";
            devices = [ "tp2" ];
          };

          "${root}/Dokumente" = {
            id = "sqkfd-m9he7";
            devices = [ "tp2" ];
          };

          "${root}/Musik" = {
            id = "zvffu-ff92z";
            devices = [ "tp2" ];
          };
        };
      };

  };

}
