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

    "applications/vim.desktop" = {
      text = lib.generators.toINI {} {
        "Desktop Entry" = {
          Name = "Vim";
          Comment = "Edit text files in a console using Vim";
          TryExec = "vim";
          Exec = "vim %F";
          Terminal = true;
          Type = "Application";
          Icon = "${pkgs.tango-icon-theme}/share/icons/Tango/scalable/apps/text-editor.svg";
          Categories = "Application;Utility;TextEditor;";
          StartupNotify = false;
          MimeType = "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;";
        };
      };
      onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
    };

  };
}
