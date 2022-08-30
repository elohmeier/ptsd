{ config, lib, pkgs, ... }:

with lib;

let
  universe = import ../../../2configs/universe.nix;
in
{
  services.syncthing = {
    enable = true;

    key = "/var/src/secrets/syncthing.key";
    cert = "/var/src/secrets/syncthing.crt";
    devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);

    folders = {
      "/tank/enc/enno/Documents" = { label = "enno/Documents"; id = "hmekh-kgprn"; devices = [ "mb4" ]; };
      "/tank/enc/enno/FPV" = { label = "enno/FPV"; id = "xxdwi-yom6n"; devices = [ "mb4" ]; };
      "/tank/enc/enno/Lightroom-Export" = { label = "enno/Lightroom-Export"; id = "uxsxc-bjqrg"; devices = [ "iph3" ]; ignoreDelete = true; };
      "/tank/enc/enno/LuNo" = { label = "enno/LuNo"; id = "3ull9-9deg4"; devices = [ "rpi4" "mb3" "mb4" ]; };
      "/tank/enc/enno/Recordings" = { label = "enno/Recordings"; id = "qihz9-vbq6o"; devices = [ "mb4" ]; };
      "/tank/enc/enno/Scans" = { label = "enno/Scans"; id = "ezjwj-xgnhe"; devices = [ "rpi4" "mb4" "iph3" ]; };
      "/tank/enc/enno/Templates" = { label = "enno/Templates"; id = "gnwqu-yt7qc"; devices = [ "mb4" ]; };
      "/tank/enc/enno/iOS" = { label = "enno/iOS"; id = "qm9ln-btyqu"; devices = [ "iph3" "mb4" "rpi4" ]; };
      "/tank/enc/fraam-gdrive-backup" = { label = "fraam-gdrive-backup"; id = "fraam-gdrive-backup"; devices = [ "rpi4" "mb4" ]; };
      "/tank/enc/luisa/Bilder" = { label = "luisa/Bilder"; id = "ugmai-ti6vl"; devices = [ "mb3" "mb4" ]; };
      "/tank/enc/luisa/Dokumente" = { label = "luisa/Dokumente"; id = "sqkfd-m9he7"; devices = [ "mb4" "mb3" ]; };
      "/tank/enc/luisa/Musik" = { label = "luisa/Musik"; id = "zvffu-ff92z"; devices = [ "mb3" "mb4" ]; };
      "/tank/enc/luisa/Scans" = { label = "luisa/Scans"; id = "dnryo-kz7io"; devices = [ "mb4" "mb3" "rpi4" ]; };
      "/tank/enc/media" = { label = "media"; id = "zfruo-ytfi2"; devices = [ "mb4" ]; };
      "/tank/enc/rawphotos/2021-06 mopedtour" = { label = "2021-06 mopedtour"; id = "ieyohHo7uang"; devices = [ "ext-arvid-laptop" ]; };
      "/tank/enc/rawphotos/photos" = { label = "photos"; id = "rqvar-xdhbm"; devices = [ "mb4" ]; };
      "/tank/enc/repos" = { label = "enno/repos"; id = "yqa69-2zjmt"; devices = [ "pine2" "mb4" ]; ignorePerms = false; };
      "/tank/enc/roms" = { label = "roms"; id = "avcjn-tyzyp"; devices = [ "mb4" ]; };
      "/var/cache/private/photoprism" = { label = "photoprism-cache"; id = "tsfyr-53d26"; devices = [ "mb4" ]; };
      "/var/lib/private/photoprism" = { label = "photoprism-lib"; id = "3tf3k-nohyy"; devices = [ "mb4" ]; };
    };
  };

  # syncthing might run a lengthy db migration
  systemd.services.syncthing-init.serviceConfig.TimeoutStartSec = "5min";
  systemd.services.syncthing.serviceConfig.TimeoutStartSec = "5min";

  boot.kernel.sysctl = {
    # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
    "fs.inotify.max_user_watches" = 204800;
  };
}
