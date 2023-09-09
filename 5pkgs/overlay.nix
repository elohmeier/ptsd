final: prev: {
  borg2prom = final.writers.writePython3Bin "borg2prom" { libraries = [ final.python3Packages.requests ]; flakeIgnore = [ "E265" "E501" ]; } ../4scripts/borg2prom.py;
  chicago95 = final.callPackage ./chicago95 { };
  copy-secrets = final.writers.writePython3Bin "copy-secrets" { flakeIgnore = [ "E265" "E501" ]; libraries = [ final.python3Packages.python-gnupg ]; } ../4scripts/copy-secrets.py;
  fritzbox-exporter = final.callPackage ./fritzbox-exporter { };
  gen-secrets = final.callPackage ./gen-secrets { };
  go-sqlcmd = final.callPackage ./go-sqlcmd { };
  gomumblesoundboard = final.callPackage ./gomumblesoundboard { };
  hashPassword = final.callPackage ./hashPassword { };
  httpserve = final.writers.writePython3Bin "httpserve" { flakeIgnore = [ "E265" "E501" ]; } ../4scripts/httpserve.py;
  linux-megi = final.callPackage ./linux-megi { };
  logseq-query = final.callPackage ./logseq-query { };
  macos-fix-filefoldernames = final.writers.writePython3Bin "macos-fix-filefoldernames" { flakeIgnore = [ "E265" ]; } ../4scripts/macos-fix-filefoldernames.py;
  monica = final.callPackage ./monica { };
  nwfonts = final.callPackage ./nwfonts { };
  pdfconcat = final.writers.writePython3Bin "pdfconcat" { flakeIgnore = [ "E203" "E501" "W503" ]; } (final.substituteAll { src = ../4scripts/pdfconcat.py; inherit (final) pdftk; });
  pdfduplex = final.callPackage ./pdfduplex { };
  pinephone-keyboard = final.callPackage ./pinephone-keyboard { };
  prettier-with-plugins = final.callPackage ./prettier-with-plugins { };
  ptsd-octoprintPlugins = import ./octoprint-plugins;
  quotes-exporter = final.callPackage ./quotes-exporter { };
  shrinkpdf = final.callPackage ./shrinkpdf { };
  syncthing-device-id = final.writers.writePython3Bin "syncthing-device-id" { flakeIgnore = [ "E203" "E265" "E501" ]; } ../4scripts/syncthing-device-id.py;
  win10fonts = final.callPackage ./win10fonts { };
  wkhtmltopdf-qt4 = final.callPackage ./wkhtmltopdf-qt4 { };
  xorgxrdp = final.callPackage ./xrdp/xorgxrdp.nix { };
  xrdp = final.callPackage ./xrdp { };

  ptsd-nnn = (final.nnn.overrideAttrs (old: {
    makeFlags = old.makeFlags ++ [ "O_GITSTATUS=1" ];

    # fix for darwin, nnn assumes homebrew gsed
    patchPhase = ''
      substituteInPlace src/nnn.c --replace '#define SED "gsed"' '#define SED "${final.gnused}/bin/sed"'
    '';
  })).override
    { withNerdIcons = true; };
  prom-checktlsa = final.writeShellScriptBin "prom-checktlsa" ''
    PATH=$PATH:${final.lib.makeBinPath (with final; [ dig gawk glibc nettools bash checkSSLCert ])}
    . ${../4scripts/prom-checktlsa.sh}
  '';

  fzf-no-fish = final.fzf.overrideAttrs (old: {
    postInstall = old.postInstall + ''
      rm -r $out/share/fish
      rm $out/share/fzf/*.fish
    '';
  });
}
