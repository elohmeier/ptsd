{ config, lib, pkgs, ... }:

with lib;

let
  universe = import ../../../2configs/universe.nix;
in
{
  systemd.services.nextcloud-reindex-syncthing-folders = {
    description = "Update the NextCloud index for folders managed by Syncthing";
    wants = [ "network.target" "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    startAt = "daily";

    script = ''
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/FPV
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Hörspiele
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/iOS
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Pocket
      /run/current-system/sw/bin/nextcloud-occ files:scan --path=enno/files/Lightroom-Export
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

  ptsd.secrets.files = {
    "syncthing.key" = { };
    "syncthing.crt" = { };
  };

  services.syncthing = {
    enable = true;

    # mirror the nextcloud permissions
    user = "nextcloud";
    group = "nginx";

    key = config.ptsd.secrets.files."syncthing.key".path;
    cert = config.ptsd.secrets.files."syncthing.crt".path;
    devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);

    folders = {
      "/tank/enc/rawphotos/2021-06 mopedtour" = {
        label = "2021-06 mopedtour";
        id = "ieyohHo7uang";
        devices = [ "ext-arvid" ];
      };

      "/tank/enc/rawphotos/photos" = {
        label = "photos";
        id = "rqvar-xdhbm";
        devices = [ "ws1" ];
      };

      "/var/lib/nextcloud/data/enno/files/FPV" = {
        label = "enno/FPV";
        id = "xxdwi-yom6n";
        devices = [ "tp1" "ws1" "ws1-win10n" ];
      };
      "/var/lib/nextcloud/data/enno/files/Pocket" = {
        label = "enno/Pocket";
        id = "hmekh-kgprn";
        devices = [ "nuc1" "tp1" "ws1" "ws2" ];
      };
      "/var/lib/nextcloud/data/enno/files/LuNo" = {
        label = "enno/LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "tp1" "tp2" "ws1" ];
      };
      "/var/lib/nextcloud/data/enno/files/Scans" = {
        label = "enno/Scans";
        id = "ezjwj-xgnhe";
        devices = [ "tp1" "ws1" "ws2" "iph3" ];
      };
      "/var/lib/nextcloud/data/enno/files/Templates" = {
        label = "enno/Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nuc1" "tp1" "ws1" "ws2" ];
      };
      "/tank/enc/repos" = {
        label = "enno/repos";
        id = "yqa69-2zjmt";
        devices = [ "tp1" "ws1" "ws2" ];
        ignorePerms = false;
      };
      "/var/lib/nextcloud/data/enno/files/iOS" = {
        label = "enno/iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" "tp1" "ws1" "ws2" ];
      };
      "/var/lib/nextcloud/data/enno/files/Lightroom-Export" = {
        label = "enno/Lightroom-Export";
        id = "uxsxc-bjqrg";
        devices = [ "iph3" ];
        ignoreDelete = true;
      };

      # "/var/lib/nextcloud/data/luisa/files/LuNo" = {
      #   id = "3ull9-9deg4";
      #   devices = [ "tp1" "tp2" "mb1" "ws1" ];
      # };

      "/var/lib/nextcloud/data/luisa/files/Bilder" = {
        label = "luisa/Bilder";
        id = "ugmai-ti6vl";
        devices = [ "tp2" "mb1" "ws1" ];
      };
      "/var/lib/nextcloud/data/luisa/files/Dokumente" = {
        label = "luisa/Dokumente";
        id = "sqkfd-m9he7";
        devices = [ "tp2" "mb1" "ws1" ];
      };
      "/var/lib/nextcloud/data/luisa/files/Musik" = {
        label = "luisa/Musik";
        id = "zvffu-ff92z";
        devices = [ "tp2" "mb1" "ws1" ];
      };
      "/var/lib/nextcloud/data/luisa/files/Scans" = {
        label = "luisa/Scans";
        id = "dnryo-kz7io";
        devices = [ "tp2" "mb1" "ws1" ];
      };
      "/var/cache/photoprism" = {
        label = "photoprism-cache";
        id = "tsfyr-53d26";
        devices = [ "ws1" ];
      };
      "/var/lib/photoprism" = {
        label = "photoprism-lib";
        id = "3tf3k-nohyy";
        devices = [ "ws1" ];
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
