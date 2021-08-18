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
      "/home/enno/Scans-Luisa" = {
        label = "Scans-Luisa";
        id = "dnryo-kz7io";
        devices = [ "nas1" ];
      };
      "/home/enno/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "tp1" "ws2" ];
      };
      "/home/enno/repos" = {
        label = "repos";
        id = "jihdi-qxmi3";
        devices = [ "nas1" "tp1" "ws2" ];
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
    };
  };
}
