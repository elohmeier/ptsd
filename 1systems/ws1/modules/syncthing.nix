{ ... }:

{

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/FPV" = {
        label = "FPV";
        id = "xxdwi-yom6n";
        devices = [ "nas1" "tp1" ];
      };
      "/home/enno/iOS" = {
        label = "iOS";
        id = "qm9ln-btyqu";
        devices = [ "nas1" "iph3" "tp1" "ws2" ];
      };
      "/home/enno/LuNo" = {
        label = "LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1" "nuc1" "tp1" "tp2" ];
      };
      "/home/enno/Pocket" = {
        label = "Pocket";
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1" "tp1-win10" "ws1-win10" "ws2" ];
      };
      "/home/enno/Scans" = {
        label = "Scans";
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "tp1" "ws2" "iph3" ];
      };
      "/home/enno/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "tp1" "ws2" ];
      };
      "/home/enno/repos" = {
        label = "repos";
        id = "yqa69-2zjmt";
        devices = [ "nas1" "tp1" "ws2" ];
        ignorePerms = false;
      };
      "/mnt/photos/photos" = {
        label = "photos";
        id = "rqvar-xdhbm";
        devices = [ "nas1" ];
      };
      "/mnt/photos/photoprism-cache" = {
        label = "photoprism-cache";
        id = "tsfyr-53d26";
        devices = [ "nas1" ];
      };
      "/mnt/photos/photoprism-lib" = {
        label = "photoprism-lib";
        id = "3tf3k-nohyy";
        devices = [ "nas1" ];
      };

      "/mnt/luisa/Bilder" = {
        label = "luisa/Bilder";
        id = "ugmai-ti6vl";
        devices = [ "tp2" "mb1" "nas1" ];
      };
      "/mnt/luisa/Dokumente" = {
        label = "luisa/Dokumente";
        id = "sqkfd-m9he7";
        devices = [ "tp1" "tp2" "mb1" "nas1" ];
      };
      "/mnt/luisa/Musik" = {
        label = "luisa/Musik";
        id = "zvffu-ff92z";
        devices = [ "tp2" "mb1" "nas1" ];
      };
      "/mnt/luisa/Scans" = {
        label = "luisa/Scans";
        id = "dnryo-kz7io";
        devices = [ "tp1" "tp2" "mb1" "nas1" ];
      };

    };
  };
}
