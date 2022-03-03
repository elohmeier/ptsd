{ ... }:

{
  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/sync/FPV" = {
        label = "FPV";
        id = "xxdwi-yom6n";
        devices = [ "nas1" "tp1-win10" "ws1" "ws1-win10" "ws1-win10n" ];
      };
      "/sync/LuNo" = {
        label = "LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1" "tp2" "ws1" ];
      };
      "/sync/Pocket" = {
        label = "Pocket";
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1-win10" "ws1" "ws1-win10" "ws2" ];
      };
      "/sync/Scans" = {
        label = "Scans";
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "ws1" "ws2" "iph3" ];
      };
      "/sync/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "nuc1" "ws1" "ws2" ];
      };
      "/sync/iOS" = {
        label = "iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" "nas1" "ws1" "ws2" ];
      };
      "/sync/repos" = {
        id = "yqa69-2zjmt";
        devices = [ "nas1" "ws1" "ws2" ];
        label = "repos";
        ignorePerms = false;
      };

      "/sync/luisa/Dokumente" = {
        label = "luisa/Dokumente";
        id = "sqkfd-m9he7";
        devices = [ "tp1" "tp2" "mb1" "nas1" ];
      };
      "/sync/luisa/Scans" = {
        label = "luisa/Scans";
        id = "dnryo-kz7io";
        devices = [ "tp1" "tp2" "mb1" "nas1" ];
      };
    };
  };
}
