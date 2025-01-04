{ self, inputs, ... }:

{
  flake.overlays = {
    default = final: prev: {
      borg2prom = final.writers.writePython3Bin "borg2prom" {
        libraries = [ final.python3Packages.requests ];
        flakeIgnore = [
          "E265"
          "E501"
        ];
      } ../../scripts/borg2prom.py;
      clan-cli = inputs.clan-core.packages.${final.system}.clan-cli;
      hashPassword = final.callPackage ../../packages/hashPassword { };
      hl = final.callPackage ../../packages/hl { };
      httpserve = final.writers.writePython3Bin "httpserve" {
        flakeIgnore = [
          "E265"
          "E501"
        ];
      } ../../scripts/httpserve.py;
      logseq-query = final.callPackage ../../packages/logseq-query { };
      macos-fix-filefoldernames = final.writers.writePython3Bin "macos-fix-filefoldernames" {
        flakeIgnore = [ "E265" ];
      } ../../scripts/macos-fix-filefoldernames.py;
      shrinkpdf = final.callPackage ../../packages/shrinkpdf { };
      syncthing-device-id = final.writers.writePython3Bin "syncthing-device-id" {
        flakeIgnore = [
          "E203"
          "E265"
          "E501"
        ];
      } ../../scripts/syncthing-device-id.py;
      win10fonts = final.callPackage ../../packages/win10fonts { };
      ptsd-nnn =
        (final.nnn.overrideAttrs (old: {
          makeFlags = old.makeFlags ++ [ "O_GITSTATUS=1" ];

          # fix for darwin, nnn assumes homebrew gsed
          patchPhase = final.lib.optionalString final.stdenv.isDarwin ''
            substituteInPlace src/nnn.c --replace '#define SED "gsed"' '#define SED "${final.gnused}/bin/sed"'
          '';
        })).override
          { withNerdIcons = true; };
      prom-checktlsa = final.callPackage ../../packages/prom-checktlsa { };
      ptsd-node-packages = final.callPackage ../../packages/node-packages { };
    };
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          inputs.attic.overlays.default
          inputs.colmena.overlays.default
          inputs.nix95.overlays.default
          inputs.nixcfg.overlays.default
          inputs.nvim-config.overlays.default
          self.overlays.default
        ];
      };
    };
}
