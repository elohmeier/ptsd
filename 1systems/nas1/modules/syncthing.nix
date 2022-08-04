{ config, lib, pkgs, ... }:

with lib;

let
  universe = import ../../../2configs/universe.nix;
in
{
  systemd.services."syncthing.service".serviceConfig.LoadCredential = [
    "syncthing.key:/var/src/secrets/syncthing.key"
    "syncthing.crt:/var/src/secrets/syncthing.crt"
  ];

  services.syncthing = {
    enable = true;

    key = "/run/credentials/syncthing.service/syncthing.key";
    cert = "/run/credentials/syncthing.service/syncthing.crt";
    devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);

    folders = {
      "/tank/enc/enno/Documents" = { label = "enno/Documents"; id = "hmekh-kgprn"; devices = [ "mb4" ]; };
      "/tank/enc/enno/FPV" = { label = "enno/FPV"; id = "xxdwi-yom6n"; devices = [ "mb4" ]; };
      "/tank/enc/enno/Lightroom-Export" = { label = "enno/Lightroom-Export"; id = "uxsxc-bjqrg"; devices = [ "iph3" ]; ignoreDelete = true; };
      "/tank/enc/enno/LuNo" = { label = "enno/LuNo"; id = "3ull9-9deg4"; devices = [ "mb1" "mb3" "mb4" ]; };
      "/tank/enc/enno/Recordings" = { label = "enno/Recordings"; id = "qihz9-vbq6o"; devices = [ "mb4" ]; };
      "/tank/enc/enno/Scans" = { label = "enno/Scans"; id = "ezjwj-xgnhe"; devices = [ "mb4" "iph3" ]; };
      "/tank/enc/enno/Templates" = { label = "enno/Templates"; id = "gnwqu-yt7qc"; devices = [ "mb4" ]; };
      "/tank/enc/enno/iOS" = { label = "enno/iOS"; id = "qm9ln-btyqu"; devices = [ "iph3" "mb4" ]; };
      "/tank/enc/luisa/Bilder" = { label = "luisa/Bilder"; id = "ugmai-ti6vl"; devices = [ "mb1" "mb3" "mb4" ]; };
      "/tank/enc/luisa/Dokumente" = { label = "luisa/Dokumente"; id = "sqkfd-m9he7"; devices = [ "mb4" "mb1" "mb3" ]; };
      "/tank/enc/luisa/Musik" = { label = "luisa/Musik"; id = "zvffu-ff92z"; devices = [ "mb1" "mb3" "mb4" ]; };
      "/tank/enc/luisa/Scans" = { label = "luisa/Scans"; id = "dnryo-kz7io"; devices = [ "mb4" "mb1" "mb3" ]; };
      "/tank/enc/media" = { label = "media"; id = "zfruo-ytfi2"; devices = [ "mb4" ]; };
      "/tank/enc/rawphotos/2021-06 mopedtour" = { label = "2021-06 mopedtour"; id = "ieyohHo7uang"; devices = [ "ext-arvid" "ext-arvid-laptop" ]; };
      "/tank/enc/rawphotos/photos" = { label = "photos"; id = "rqvar-xdhbm"; devices = [ "mb4" ]; };
      "/tank/enc/repos" = { label = "enno/repos"; id = "yqa69-2zjmt"; devices = [ "pine2" "mb4" ]; ignorePerms = false; };
      "/tank/enc/roms" = { label = "roms"; id = "avcjn-tyzyp"; devices = [ "mb4" ]; };
      "/var/cache/photoprism" = { label = "photoprism-cache"; id = "tsfyr-53d26"; devices = [ "mb4" ]; };
      "/var/lib/photoprism" = { label = "photoprism-lib"; id = "3tf3k-nohyy"; devices = [ "mb4" ]; };
    };
  };

  # syncthing might run a lengthy db migration
  systemd.services."syncthing-init.service".serviceConfig.TimeoutStartSec = "5min";
  systemd.services."syncthing.service".serviceConfig.TimeoutStartSec = "5min";

  boot.kernel.sysctl = {
    # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
    "fs.inotify.max_user_watches" = 204800;
  };

  # auto-update logseq repo
  systemd.services.logseq-sync-git = {
    description = "Sync logseq repo";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "network-online.target" ];

    script = ''
      git config --global user.email "logseq-sync-git@nas1"
      git config --global user.name "logseq-sync-git@nas1"
      git add .
      git commit -m "autoupdate" || true
      git pull --rebase=merges
      git push origin main
    '';

    path = with pkgs; [ git openssh ];
    environment = {
      GIT_SSH_COMMAND = "ssh -i /run/credentials/logseq-sync-git.service/id_ed25519";
    };

    serviceConfig = {
      User = "syncthing";
      Group = "syncthing";
      LoadCredential = "id_ed25519:/var/src/secrets/nwbackup.id_ed25519";
      WorkingDirectory = "/tank/enc/repos/logseq";
    };
  };

  systemd.timers.logseq-sync-git = {
    description = "Sync logseq repo";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "1min";
      OnUnitInactiveSec = "1min";
    };
  };
}
