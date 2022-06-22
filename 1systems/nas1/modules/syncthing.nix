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
        devices = [ "ws1" "mb4" ];
      };
      "/tank/enc/enno/FPV" = {
        label = "enno/FPV";
        id = "xxdwi-yom6n";
        devices = [ "mb4" "ws1" ];
      };
      "/tank/enc/enno/Pocket" = {
        label = "enno/Pocket";
        id = "hmekh-kgprn";
        devices = [ "mb4" "ws1" ];
      };
      "/tank/enc/enno/LuNo" = {
        label = "enno/LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "mb3" "mb4" "ws1" ];
      };
      "/tank/enc/enno/Scans" = {
        label = "enno/Scans";
        id = "ezjwj-xgnhe";
        devices = [ "mb4" "ws1" "iph3" ];
      };
      "/tank/enc/enno/Templates" = {
        label = "enno/Templates";
        id = "gnwqu-yt7qc";
        devices = [ "mb4" "ws1" ];
      };
      "/tank/enc/repos" = {
        label = "enno/repos";
        id = "yqa69-2zjmt";
        devices = [ "pine2" "mb4" "ws1" ];
        ignorePerms = false;
      };
      "/tank/enc/enno/iOS" = {
        label = "enno/iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" "mb4" "ws1" ];
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
        devices = [ "mb1" "mb3" "ws1" "mb4" ];
      };
      "/tank/enc/luisa/Dokumente" = {
        label = "luisa/Dokumente";
        id = "sqkfd-m9he7";
        devices = [ "mb4" "mb1" "mb3" "ws1" ];
      };
      "/tank/enc/luisa/Musik" = {
        label = "luisa/Musik";
        id = "zvffu-ff92z";
        devices = [ "mb1" "mb3" "ws1" "mb4" ];
      };
      "/tank/enc/luisa/Scans" = {
        label = "luisa/Scans";
        id = "dnryo-kz7io";
        devices = [ "mb4" "mb1" "mb3" "ws1" ];
      };

      "/var/cache/photoprism" = {
        label = "photoprism-cache";
        id = "tsfyr-53d26";
        devices = [ "ws1" "mb4" ];
      };
      "/var/lib/photoprism" = {
        label = "photoprism-lib";
        id = "3tf3k-nohyy";
        devices = [ "ws1" "mb4" ];
      };

      "/tank/enc/media" = {
        label = "media";
        id = "zfruo-ytfi2";
        devices = [ "mb4" ];
      };

      "/tank/enc/roms" = {
        label = "roms";
        id = "avcjn-tyzyp";
        devices = [ "mb4" ];
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
