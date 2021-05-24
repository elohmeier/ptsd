{ config, lib, pkgs, ... }:

with lib;
let
  universe = import ./universe.nix;

  domain = "nextcloud.services.nerdworks.de";
  nextcloudUid = 131; # unused as of 19.09, old docker uid
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

  users.groups.keys.members = [ "nextcloud" ];

  ptsd.secrets.files."ncadmin-pw" = {
    owner = "nextcloud";
    group-name = "nextcloud";
    dependants = [ "nextcloud-setup.service" ];
  };

  # this is not set inside nixpkgs for NextCloud as of 19.09
  users.users.nextcloud = {
    isSystemUser = true;
    uid = nextcloudUid;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud21;
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
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/FPV
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Hörspiele
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Pocket
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/LuNo
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Scans
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Templates
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=luisa/files/LuNo
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=luisa/files/Bilder
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=luisa/files/Dokumente
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=luisa/files/Musik
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=luisa/files/Scans
    '';

    serviceConfig = {
      User = "nextcloud";
    };
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
        entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
      }
    ];
  };

  ptsd.secrets.files = {
    "syncthing.key" = { };
    "syncthing.crt" = { };
  };

  services.syncthing = {
    enable = true;

    # mirror the nextcloud permissions
    user = "nextcloud";
    group = "nginx";

    declarative = {
      key = config.ptsd.secrets.files."syncthing.key".path;
      cert = config.ptsd.secrets.files."syncthing.crt".path;
      devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);

      folders = {
        "/var/lib/nextcloud/data/enno/files/FPV" = {
          id = "xxdwi-yom6n";
          devices = [ "tp1" "ws1" "ws1-win10n" ];
        };
        "/var/lib/nextcloud/data/enno/files/Hörspiele" = {
          id = "rqnvn-lmhcm";
          devices = [ "ext-arvid" "tp1" ];
          type = "receiveonly";
        };
        "/var/lib/nextcloud/data/enno/files/Pocket" = {
          id = "hmekh-kgprn";
          devices = [ "nuc1" "tp1" "ws1" "ws2" ];
        };
        "/var/lib/nextcloud/data/enno/files/LuNo" = {
          id = "3ull9-9deg4";
          devices = [ "mb1" "tp1" "tp2" "ws1" ];
        };
        "/var/lib/nextcloud/data/enno/files/Scans" = {
          id = "ezjwj-xgnhe";
          devices = [ "tp1" "ws1" ];
        };
        "/var/lib/nextcloud/data/enno/files/Templates" = {
          id = "gnwqu-yt7qc";
          devices = [ "nuc1" "tp1" "ws1" "ws2" ];
        };
        "/var/lib/nextcloud/data/enno/files/repos-ws1" = {
          id = "jihdi-qxmi3";
          devices = [ "tp1" "ws1" ];
        };

        # "/var/lib/nextcloud/data/luisa/files/LuNo" = {
        #   id = "3ull9-9deg4";
        #   devices = [ "tp1" "tp2" "mb1" "ws1" ];
        # };

        "/var/lib/nextcloud/data/luisa/files/Bilder" = {
          id = "ugmai-ti6vl";
          devices = [ "tp2" "mb1" ];
        };
        "/var/lib/nextcloud/data/luisa/files/Dokumente" = {
          id = "sqkfd-m9he7";
          devices = [ "tp2" "mb1" ];
        };
        "/var/lib/nextcloud/data/luisa/files/Musik" = {
          id = "zvffu-ff92z";
          devices = [ "tp2" "mb1" ];
        };
        "/var/lib/nextcloud/data/luisa/files/Scans" = {
          id = "dnryo-kz7io";
          devices = [ "tp2" "mb1" "ws1" ];
        };
      };
    };
  };

  # syncthing might run a lengthy db migration
  systemd.services."syncthing-init.service".serviceConfig.TimeoutStartSec = "5min";
  systemd.services."syncthing.service".serviceConfig.TimeoutStartSec = "5min";

  boot.kernel.sysctl = {
    # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
    "fs.inotify.max_user_watches" = 204800;
  };
}
