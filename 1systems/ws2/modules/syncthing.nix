{ ... }:

{
  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/iOS" = {
        label = "iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" "nas1" "ws1" ];
      };
      "/home/enno/Pocket" = {
        label = "Pocket";
        id = "hmekh-kgprn";
        devices = [ "nas1" "ws1" "ws1-win10" ];
      };
      "/home/enno/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "ws1" ];
      };
      "/home/enno/Scans" = {
        label = "Scans";
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "ws1" "iph3" ];
      };
      "/home/enno/repos" = {
        label = "repos";
        id = "yqa69-2zjmt";
        devices = [ "nas1" "ws1" ];
        ignorePerms = false;
      };
    };
  };
}
