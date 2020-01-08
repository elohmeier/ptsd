{ config, lib, pkgs, ... }:

{

  xdg.dataFile = {

    "file-manager/actions/nobbofin_assign_fzf.desktop".text = lib.generators.toINI {} {
      "Desktop Entry" = {
        Type = "Action";
        Name = "Assign PDF to Nobbofin Transaction";
        "Name[de]" = "PDF Nobbofin-Transaktion zuordnen";
        Profiles = "assign;";
      };

      "X-Action-Profile assign" = {
        MimeTypes = "application/pdf";
        Exec = "i3-sensible-terminal -e /home/enno/nobbofin/assign-doc-fzf.py %f";
      };
    };

    "file-manager/actions/sylpheed_attach.desktop".text = lib.generators.toINI {} {
      "Desktop Entry" = {
        Type = "Action";
        Name = "Send via E-Mail (Sylpheed)";
        "Name[de]" = "Per E-Mail senden (Sylpheed)";
        Profiles = "attach;";
      };

      "X-Action-Profile attach" = {
        MimeTypes = "*";
        Exec = "sylpheed --attach %F";
      };
    };

  };

}
