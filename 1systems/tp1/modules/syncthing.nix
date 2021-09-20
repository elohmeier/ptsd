{ ... }:

{
  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/FPV" = {
        label = "FPV";
        id = "xxdwi-yom6n";
        devices = [ "nas1" "tp1-win10" "ws1" "ws1-win10" "ws1-win10n" ];
      };
      # "/home/enno/Hörspiele" = {
      #   id = "rqnvn-lmhcm";
      #   devices = [ "ext-arvid" "nas1" ];
      #   type = "sendonly";
      # };
      "/home/enno/LuNo" = {
        label = "LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1" "tp2" "ws1" ];
      };
      "/home/enno/Pocket" = {
        label = "Pocket";
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1-win10" "ws1" "ws1-win10" "ws2" ];
      };
      "/home/enno/Scans" = {
        label = "Scans";
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "ws1" "ws2" "iph3" ];
      };
      "/home/enno/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "nuc1" "ws1" "ws2" ];
      };
      "/home/enno/iOS" = {
        label = "iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" "nas1" "ws1" "ws2" ];
      };
      "/home/enno/repos" = {
        id = "yqa69-2zjmt";
        devices = [ "nas1" "ws1" "ws2" ];
        label = "repos";
        ignorePerms = false;
      };
    };
  };
}
