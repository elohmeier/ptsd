{ config, lib, pkgs, ... }:

with lib;

let
  universe = import ../../../2configs/universe.nix;
in
{
  ptsd.secrets.files = {
    "syncthing.key" = { };
    "syncthing.crt" = { };
  };

  services.syncthing = {
    enable = true;

    key = config.ptsd.secrets.files."syncthing.key".path;
    cert = config.ptsd.secrets.files."syncthing.crt".path;
    devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);

    folders = {
      "/tank/enc/rawphotos/2021-06 mopedtour" = {
        label = "2021-06 mopedtour";
        id = "ieyohHo7uang";
        devices = [ "ext-arvid" "ext-arvid-laptop" ];
      };

      "/tank/enc/rawphotos/photos" = {
        label = "photos";
        id = "rqvar-xdhbm";
        devices = [ "ws1" ];
      };

      "/tank/enc/enno/FPV" = {
        label = "enno/FPV";
        id = "xxdwi-yom6n";
        devices = [ "tp1" "ws1" "ws1-win10n" ];
      };
      "/tank/enc/enno/Pocket" = {
        label = "enno/Pocket";
        id = "hmekh-kgprn";
        devices = [ "nuc1" "tp1" "ws1" "ws2" ];
      };
      "/tank/enc/enno/LuNo" = {
        label = "enno/LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "tp1" "tp2" "ws1" ];
      };
      "/tank/enc/enno/Scans" = {
        label = "enno/Scans";
        id = "ezjwj-xgnhe";
        devices = [ "tp1" "ws1" "ws2" "iph3" ];
      };
      "/tank/enc/enno/Templates" = {
        label = "enno/Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nuc1" "tp1" "ws1" "ws2" ];
      };
      "/tank/enc/repos" = {
        label = "enno/repos";
        id = "yqa69-2zjmt";
        devices = [ "pine2" "tp1" "ws1" "ws2" ];
        ignorePerms = false;
      };
      "/tank/enc/enno/iOS" = {
        label = "enno/iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" "tp1" "ws1" "ws2" ];
      };
      "/tank/enc/enno/Lightroom-Export" = {
        label = "enno/Lightroom-Export";
        id = "uxsxc-bjqrg";
        devices = [ "iph3" ];
        ignoreDelete = true;
      };

      "/tank/enc/luisa/Bilder" = {
        label = "luisa/Bilder";
        id = "ugmai-ti6vl";
        devices = [ "tp2" "mb1" "ws1" ];
      };
      "/tank/enc/luisa/Dokumente" = {
        label = "luisa/Dokumente";
        id = "sqkfd-m9he7";
        devices = [ "tp1" "tp2" "mb1" "ws1" ];
      };
      "/tank/enc/luisa/Musik" = {
        label = "luisa/Musik";
        id = "zvffu-ff92z";
        devices = [ "tp2" "mb1" "ws1" ];
      };
      "/tank/enc/luisa/Scans" = {
        label = "luisa/Scans";
        id = "dnryo-kz7io";
        devices = [ "tp1" "tp2" "mb1" "ws1" ];
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
