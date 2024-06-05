{ self, inputs, ... }:

{
  flake.overlays = {
    default = final: prev:
      let
        pkgsUnstable = import inputs.nixpkgs-unstable {
          inherit (final) system;
        };
      in
      {
        borg2prom = final.writers.writePython3Bin "borg2prom" { libraries = [ final.python3Packages.requests ]; flakeIgnore = [ "E265" "E501" ]; } ../../scripts/borg2prom.py;
        copy-secrets = final.writers.writePython3Bin "copy-secrets" { flakeIgnore = [ "E265" "E501" ]; libraries = [ final.python3Packages.python-gnupg ]; } ../../scripts/copy-secrets.py;
        #   fritzbox-exporter = final.callPackage ./fritzbox-exporter { };
        gen-secrets = final.callPackage ../../packages/gen-secrets { };
        #   go-sqlcmd = final.callPackage ./go-sqlcmd { };
        #   gomumblesoundboard = final.callPackage ./gomumblesoundboard { };
        hashPassword = final.callPackage ../../packages/hashPassword { };
        httpserve = final.writers.writePython3Bin "httpserve" { flakeIgnore = [ "E265" "E501" ]; } ../../scripts/httpserve.py;
        #   linux-megi = final.callPackage ./linux-megi { };
        logseq-query = final.callPackage ../../packages/logseq-query { };
        macos-fix-filefoldernames = final.writers.writePython3Bin "macos-fix-filefoldernames" { flakeIgnore = [ "E265" ]; } ../../scripts/macos-fix-filefoldernames.py;
        monica = final.callPackage ../../packages/monica { };
        #   nwfonts = final.callPackage ./nwfonts { };
        #   pdfconcat = final.writers.writePython3Bin "pdfconcat" { flakeIgnore = [ "E203" "E501" "W503" ]; } (final.substituteAll { src = ../4scripts/pdfconcat.py; inherit (final) pdftk; });
        #   pdfduplex = final.callPackage ./pdfduplex { };
        #   pinephone-keyboard = final.callPackage ./pinephone-keyboard { };
        prettier-with-plugins = final.callPackage ../../packages/prettier-with-plugins { };
        #   ptsd-octoprintPlugins = import ./octoprint-plugins;
        #   quotes-exporter = final.callPackage ./quotes-exporter { };
        shrinkpdf = final.callPackage ../../packages/shrinkpdf { };
        syncthing-device-id = final.writers.writePython3Bin "syncthing-device-id" { flakeIgnore = [ "E203" "E265" "E501" ]; } ../../scripts/syncthing-device-id.py;
        win10fonts = final.callPackage ../../packages/win10fonts { };
        attic-client = final.callPackage ../../packages/attic { clientOnly = true; };
        #   wkhtmltopdf-qt4 = final.callPackage ./wkhtmltopdf-qt4 { };
        #   xorgxrdp = final.callPackage ./xrdp/xorgxrdp.nix { };
        #   xrdp = final.callPackage ./xrdp { };
        #
        ptsd-nnn = (final.nnn.overrideAttrs (old: {
          makeFlags = old.makeFlags ++ [ "O_GITSTATUS=1" ];

          # fix for darwin, nnn assumes homebrew gsed
          patchPhase = ''
            substituteInPlace src/nnn.c --replace '#define SED "gsed"' '#define SED "${final.gnused}/bin/sed"'
          '';
        })).override
          { withNerdIcons = true; };
        prom-checktlsa = final.callPackage ../../packages/prom-checktlsa { };

        fzf-no-fish = final.fzf.overrideAttrs (old: {
          postInstall = old.postInstall + ''
            rm -r $out/share/fish
            rm $out/share/fzf/*.fish
          '';
        });

        ollama_unstable = pkgsUnstable.ollama;
        llama-cpp_unstable = pkgsUnstable.llama-cpp;

        paperless-ngx_unstable = pkgsUnstable.paperless-ngx;
      };
  };

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.colmena.overlays.default
        inputs.nixcfg.overlays.default
        inputs.nix95.overlays.default
        self.overlays.default
      ];
    };

    _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.colmena.overlays.default
        inputs.nixcfg.overlays.default
        inputs.nix95.overlays.default
        self.overlays.default
      ];
    };
  };
}
