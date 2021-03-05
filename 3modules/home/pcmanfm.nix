{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.pcmanfm;
  rdp-assi = prog: pkgs.writers.writeDash "rdp-assi" ''
    ${pkgs.writers.writePython3 "rdp-assi-client" { } (builtins.readFile ../../src/rdp-assi-client.py)} "${prog}" "$@"
  '';
  generateXdgAction = id: action: nameValuePair
    "file-manager/actions/${id}.desktop"
    {
      text = lib.generators.toINI { } {
        "Desktop Entry" = {
          Type = "Action";
          Name = action.title;
          Profiles = "${id};";
        } // optionalAttrs (action.title_de != null) {
          "Name[de]" = action.title_de;
        };

        "X-Action-Profile ${id}" = {
          MimeTypes = concatStringsSep ";" action.mimetypes;
          Exec = action.cmd;
        } // optionalAttrs (action.selectionCount != null) {
          SelectionCount = action.selectionCount;
        };
      };
    };
  generateXdgThumbnailer = id: thumbnailer: nameValuePair
    "thumbnailers/${id}.thumbnailer"
    {
      text = lib.generators.toINI { } {
        "Thumbnailer Entry" = {
          Exec = thumbnailer.cmd;
          MimeType = concatStringsSep ";" thumbnailer.mimetypes;
        };
      };
    };
in
{
  options.ptsd.pcmanfm = {
    enable = mkEnableOption "pcmanfm";
    enableRdpAssistant = mkEnableOption "rdp-assistant";
    term = mkOption {
      type = types.str;
    };
    actions = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }: {
            options = {
              id = mkOption {
                type = types.str;
                default = config._module.args.name;
              };

              title = mkOption {
                type = types.str;
              };

              title_de = mkOption {
                type = with types; nullOr str;
                default = null;
              };

              mimetypes = mkOption {
                type = with types; listOf str;
              };

              cmd = mkOption {
                type = types.str;
              };

              selectionCount = mkOption {
                type = types.nullOr types.int;
                default = null;
              };
            };
          }
        )
      );
      default = { };
    };

    thumbnailers = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }: {
            options = {
              id = mkOption {
                type = types.str;
                default = config._module.args.name;
              };

              mimetypes = mkOption {
                type = with types; listOf str;
              };

              cmd = mkOption {
                type = types.str;
              };
            };
          }
        )
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {

    xdg.configFile = {
      "libfm/libfm.conf" = {
        text = lib.generators.toINI { } {
          config = {
            terminal = cfg.term;
          };
        };
        force = true;
      };
    };

    xdg.dataFile =

      (
        mapAttrs' generateXdgAction cfg.actions
      ) //
      (
        mapAttrs' generateXdgThumbnailer cfg.thumbnailers
      ) //

      {

        # not working
        # "mime/application/vnd.jgraph.mxfile.xml".text = ''
        #   <?xml version="1.0" encoding="utf-8"?>
        #   <mime-type xmlns="http://www.freedesktop.org/standards/shared-mime-info" type="application/vnd.jgraph.mxfile">
        #     <comment>JGraph MXFile</comment>
        #     <glob pattern="*.drawio"/>
        #   </mime-type>
        # '';

        "file-manager/actions/nobbofin_assign_fzf.desktop".text = lib.generators.toINI
          { }
          {
            "Desktop Entry" = {
              Type = "Action";
              Name = "Assign PDF to Nobbofin Transaction";
              "Name[de]" = "PDF Nobbofin-Transaktion zuordnen";
              Profiles = "nobbofin_assign_fzf;";
            };

            "X-Action-Profile nobbofin_assign_fzf" = {
              MimeTypes = "application/pdf";
              Exec = "alacritty -e /home/enno/repos/nobbofin/assign-doc-fzf.py %f";
            };
          };

        "file-manager/actions/sylpheed_attach.desktop".text = lib.generators.toINI
          { }
          {
            "Desktop Entry" = {
              Type = "Action";
              Name = "Send via E-Mail (Sylpheed)";
              "Name[de]" = "Per E-Mail senden (Sylpheed)";
              Profiles = "sylpheed_attach;";
              Icon = "sylpheed";
            };

            "X-Action-Profile sylpheed_attach" = {
              MimeTypes = "all/allfiles";
              Exec = "sylpheed --attach %F";
            };
          };

        "file-manager/actions/xdg_attach.desktop".text = lib.generators.toINI
          { }
          {
            "Desktop Entry" = {
              Type = "Action";
              Name = "Send via E-Mail (xdg-email)";
              "Name[de]" = "Per E-Mail senden (xdg-email)";
              Profiles = "xdg_attach;";
              Icon = "evolution";
            };

            "X-Action-Profile xdg_attach" = {
              MimeTypes = "all/allfiles";
              Exec = "xdg-email --attach %F";
            };
          };

        "file-manager/actions/codium.desktop".text = lib.generators.toINI
          { }
          {
            "Desktop Entry" = {
              Type = "Action";
              Name = "Open folder in VSCodium";
              "Name[de]" = "Ordner in VSCodium öffnen";
              Profiles = "codium;";
            };

            "X-Action-Profile codium" = {
              MimeTypes = "inode/directory";
              Exec = "codium %F";
            };
          };

        "file-manager/actions/print-lp.desktop".text = lib.generators.toINI
          { }
          {
            "Desktop Entry" = {
              Type = "Action";
              Name = "Print (lp)";
              "Name[de]" = "Drucken (lp)";
              Profiles = "print;";
            };

            "X-Action-Profile print" = {
              MimeTypes = "application/pdf";
              Exec = "${pkgs.cups}/bin/lp %F";
            };
          };

        "file-manager/actions/pdf2svg.desktop".text = lib.generators.toINI
          { }
          {
            "Desktop Entry" = {
              Type = "Action";
              Name = "Convert PDF to SVG";
              "Name[de]" = "Konvertiere PDF zu SVG";
              Profiles = "pdf2svg;";
            };

            "X-Action-Profile pdf2svg" = {
              MimeTypes = "application/pdf";
              Exec = "pdf2svg %f %f.svg";
            };
          };

        "applications/fava.desktop" = {
          text = lib.generators.toINI
            { }
            {
              "Desktop Entry" = {
                Name = "Fava";
                TryExec = "fava";
                Exec = "fava %F";
                Terminal = true;
                Type = "Application";
                StartupNotify = false;
                MimeType = "text/plain;";
              };
            };
          onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
        };

        "applications/vim.desktop" = {
          text = lib.generators.toINI
            { }
            {
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
      } // optionalAttrs cfg.enableRdpAssistant {
        "applications/excel-rdp.desktop" =
          {
            text = lib.generators.toINI
              { }
              {
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
            text = lib.generators.toINI
              { }
              {
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
            text = lib.generators.toINI
              { }
              {
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

    home.packages = with pkgs; [
      feh # image viewer
      sxiv # image viewer
      lxmenu-data # pcmanfm: show "installed applications"
      shared_mime_info # pcmanfm: recognise different file types
      pcmanfm
    ] ++ optionals cfg.enableRdpAssistant [
      (writers.writeDashBin "excel-rdp" ''${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE"}'')
      (writers.writeDashBin "word-rdp" ''${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE"}'')
      (writers.writeDashBin "powerpoint-rdp" ''${rdp-assi "C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE"}'')
    ];
  };
}
