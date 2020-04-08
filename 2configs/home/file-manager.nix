{ config, lib, pkgs, ... }:

let
  rdp-assi = prog: pkgs.writers.writeDash "rdp-assi" ''
    ${pkgs.writers.writePython3 "rdp-assi-client" {} (builtins.readFile ../../src/rdp-assi-client.py)} "${prog}" "$@"
  '';
in
{
  xdg.dataFile = {

    # not working
    # "mime/application/vnd.jgraph.mxfile.xml".text = ''
    #   <?xml version="1.0" encoding="utf-8"?>
    #   <mime-type xmlns="http://www.freedesktop.org/standards/shared-mime-info" type="application/vnd.jgraph.mxfile">
    #     <comment>JGraph MXFile</comment>
    #     <glob pattern="*.drawio"/>
    #   </mime-type>
    # '';

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

    "file-manager/actions/pdf2svg.desktop".text = lib.generators.toINI {} {
      "Desktop Entry" = {
        Type = "Action";
        Name = "Convert PDF to SVG";
        "Name[de]" = "Konvertiere PDF zu SVG";
        Profiles = "pdf2svg;";
      };

      "X-Action-Profile pdf2svg" = {
        MimeTypes = "application/pdf";
        Exec = "${pkgs.pdf2svg}/bin/pdf2svg %f %f.svg";
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

    "applications/excel-rdp.desktop" =
      {
        text = lib.generators.toINI {} {
          "Desktop Entry" = {
            Name = "Excel (RDP)";
            Comment = "Edit file using Excel via RDP";
            Exec = "${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"} --arg %F";
            #Terminal = true; # uncomment to debug rdp-assi-client.py
            Type = "Application";
            MimeType = "application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.openxmlformats-officedocument.spreadsheetml.template;application/vnd.ms-excel.sheet.macroEnabled.12;application/vnd.ms-excel.template.macroEnabled.12;application/vnd.oasis.opendocument.spreadsheet;";
          };
        };
        onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
      };

    "applications/word-rdp.desktop" =
      {
        text = lib.generators.toINI {} {
          "Desktop Entry" = {
            Name = "Word (RDP)";
            Comment = "Edit file using Word via RDP";
            Exec = "${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"} --arg %F";
            #Terminal = true; # uncomment to debug rdp-assi-client.py
            Type = "Application";
            MimeType = "application/msword;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/vnd.openxmlformats-officedocument.wordprocessingml.template;application/vnd.oasis.opendocument.text;";
          };
        };
        onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
      };

    "applications/powerpoint-rdp.desktop" =
      {
        text = lib.generators.toINI {} {
          "Desktop Entry" = {
            Name = "PowerPoint (RDP)";
            Comment = "Edit file using PowerPoint via RDP";
            Exec = "${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE"} --arg %F";
            #Terminal = true; # uncomment to debug rdp-assi-client.py
            Type = "Application";
            MimeType = "application/vnd.ms-powerpoint;application/vnd.openxmlformats-officedocument.presentationml.presentation;application/vnd.openxmlformats-officedocument.presentationml.template;application/vnd.oasis.opendocument.presentation;";
          };
        };
        onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
      };
  };

  home.packages = [
    (pkgs.writers.writeDashBin "excel-rdp" ''${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"}'')
    (pkgs.writers.writeDashBin "word-rdp" ''${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"}'')
    (pkgs.writers.writeDashBin "powerpoint-rdp" ''${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE"}'')
  ];
}
