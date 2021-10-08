{ nixosConfig, config, lib, pkgs, ... }:

let
  cfg = nixosConfig.ptsd.desktop;
in
{
  xdg =
    {
      mimeApps = {
        enable = true;

        # verify using `xdg-mime query default <mimetype>`
        defaultApplications = {
          "application/pdf" = [ "zathura.desktop" ];
          "text/plain" = [ "vim.desktop" ];
          "text/x-script.python" = [ "vim.desktop" ];
          "image/gif" = [ "sxiv.desktop" ];
          "image/heic" = [ "sxiv.desktop" ];
          "image/jpeg" = [ "sxiv.desktop" ];
          "image/png" = [ "sxiv.desktop" ];
          "inode/directory" = [ "pcmanfm.desktop" ];
          "text/html" = [ cfg.defaultBrowser ];
          "x-scheme-handler/http" = [ cfg.defaultBrowser ];
          "x-scheme-handler/https" = [ cfg.defaultBrowser ];
          "x-scheme-handler/about" = [ cfg.defaultBrowser ];
          "x-scheme-handler/unknown" = [ cfg.defaultBrowser ];
          "x-scheme-handler/msteams" = [ "teams.desktop" ];
          "application/vnd.jgraph.mxfile" = [ "drawio.desktop" ];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
          "application/msword" = [ "writer.desktop" ];
          "application/msexcel" = [ "calc.desktop" ];
          "application/mspowerpoint" = [ "impress.desktop" ];
          "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
          "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
          "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
        };
      };

      # force overwrite of mimeapps.list, since it will be manipulated by some desktop apps without asking
      configFile."mimeapps.list".force = true;

      dataFile = {

        "applications/choose-browser.desktop" =
          {
            text = lib.generators.toINI
              { }
              {
                "Desktop Entry" = {
                  Categories = "Network;WebBrowser;";
                  Name = "Choose Browser";
                  Comment = "";
                  Exec = "${pkgs.choose-browser}/bin/choose-browser %U";
                  Terminal = false;
                  Type = "Application";
                  MimeType = "text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp";
                  GenericName = "Web Browser";
                };
              };
            onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
          };

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
              Exec = cfg.term.execFloating "/home/enno/repos/nobbofin/assign-doc-fzf.py %f" "";
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
                Exec = cfg.term.exec "vim %F" "";
                Terminal = false;
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
    };
}
