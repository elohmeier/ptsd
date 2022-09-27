self: pkgs_master: "nixpkgs_master:neovim-flake:" super:
{
  copy-secrets = self.writers.writePython3Bin "copy-secrets"
    {
      flakeIgnore = [ "E265" "E501" ];
      libraries = [ self.python3Packages.python-gnupg ];
    } ../4scripts/copy-secrets.py;

  macos-fix-filefoldernames = self.writers.writePython3Bin "macos-fix-filefoldernames" { flakeIgnore = [ "E265" ]; } ../4scripts/macos-fix-filefoldernames.py;
  logseq-query = self.callPackage ./logseq-query { };
  tensorflow1 = self.callPackage ./tensorflow1/bin.nix { };
  subler-bin = self.callPackage ./subler-bin { };
  art = self.callPackage ./art { };
  add-workspace = self.writers.writePython3 "add-workspace"
    {
      libraries = [ self.python3Packages.i3ipc ];
      flakeIgnore = [ "E501" ];
    }
    ../4scripts/add_workspace.py;
  autoname-workspaces =
    self.writers.writePython3
      "autoname-workspaces"
      {
        libraries = [ self.python3Packages.i3ipc ];
        flakeIgnore = [ "E501" ];
      }
      ../4scripts/autoname_workspaces.py;
  betaflight-configurator = super.betaflight-configurator.overrideAttrs
    (old: {
      version = "10.8.0-RC7";
      src = self.fetchurl {
        url = "https://github.com/betaflight/betaflight-configurator/releases/download/10.8.0-RC7/betaflight-configurator_10.8.0_linux64-portable.zip";
        sha256 = "sha256-ebTZtpPhZAp2zB9v1WRk3VtHjGtGL7bAJkLp/DCyIFo=";
      };
    });
  choose-browser = self.writers.writeDashBin "choose-browser" ../4scripts/choose-browser.sh;
  fritzbox-exporter = self.callPackage ./fritzbox-exporter { };
  gen-secrets = self.callPackage ./gen-secrets { };
  gomumblesoundboard = self.callPackage ./gomumblesoundboard { };
  hashPassword = self.callPackage ./hashPassword { };
  httpserve = self.writers.writePython3Bin "httpserve" { flakeIgnore = [ "E265" "E501" ]; } ../4scripts/httpserve.py;
  lz4json = self.callPackage ./lz4json { };
  monica = self.callPackage ./monica { };
  nbconvert = self.callPackage ./nbconvert { };
  go-sqlcmd = self.callPackage ./go-sqlcmd { };
  nwfonts = self.callPackage ./nwfonts { };
  nwvpn-plain = self.callPackage ./nwvpn-plain { };
  nwvpn-qr = self.callPackage ./nwvpn-qr { };
  pdfconcat = self.writers.writePython3Bin "pdfconcat"
    {
      flakeIgnore = [ "E203" "E501" "W503" ];
    }
    (self.substituteAll {
      src = ../4scripts/pdfconcat.py;
      inherit (self) pdftk;
    });
  pdfduplex = self.callPackage ./pdfduplex { };
  photoprism = self.callPackage ./photoprism { };
  ptsdbootstrap = self.callPackage ./ptsdbootstrap { };
  quotes-exporter = self.callPackage ./quotes-exporter { };
  read-co2-status = self.writeShellScriptBin "read-co2-status" ../4scripts/read-co2-status.sh;
  read-battery-status = self.writeShellScriptBin "read-battery-status" ../4scripts/read-battery-status.sh;
  read-mediaplayer-status = self.writeShellScriptBin "read-mediaplayer-status" ''
    export GI_TYPELIB_PATH=${self.gobject-introspection}/lib/girepository-1.0:${self.playerctl}/lib/girepository-1.0
    ${self.python3.withPackages (p: [ p.pygobject3 ])}/bin/python ${../4scripts/read-mediaplayer-status.py}
  '';
  shrinkpdf = self.callPackage ./shrinkpdf { };
  swayassi = self.callPackage ./swayassi { };
  syncthing-device-id = self.writers.writePython3Bin
    "syncthing-device-id"
    { flakeIgnore = [ "E203" "E265" "E501" ]; }
    ../4scripts/syncthing-device-id.py;
  win10fonts = self.callPackage ./win10fonts { };
  wkhtmltopdf-qt4 = self.callPackage ./wkhtmltopdf-qt4 { };

  ptsd-octoprintPlugins = plugins: {
    firmwareupdater = plugins.callPackage ./octoprint-plugins/firmwareupdater.nix { };
    prusalevelingguide = plugins.callPackage ./octoprint-plugins/prusalevelingguide.nix { };
    prusaslicerthumbnails = plugins.callPackage ./octoprint-plugins/prusaslicerthumbnails.nix { };
  };

  ptsd-python3 = self.python310.override {
    packageOverrides = self: super: rec {

      black = super.black.overridePythonAttrs (old: {
        propagatedBuildInputs = with super; (

          # required uvloop dependency requires broken pyopenssl
          # waits for https://github.com/pyca/pyopenssl/issues/873
          if self.stdenv.isDarwin then [
            click
            mypy-extensions
            pathspec
            platformdirs
            tomli
          ] else old.propagatedBuildInputs
        ) ++ [
          # support reformatting ipynb files
          ipython
          tokenize-rt
        ];
        doCheck = self.stdenv.isLinux;
      });

      davphonebook = self.callPackage ./davphonebook { };
      finance-dl = self.callPackage ./finance-dl { };
      hocr-tools = self.callPackage ./hocr-tools { };
      icloudpd = self.callPackage ./icloudpd { };
      neo4j-driver = self.callPackage ./neo4j-driver { };
      nobbofin = self.callPackage ./nobbofin { };
      postgrest-py = self.callPackage ./postgrest-py { };
      pyxlsb = self.callPackage ./pyxlsb { };
      selenium-requests = self.callPackage ./selenium-requests { };
      sqlacodegen = self.callPackage ./sqlacodegen { };
      vidcutter = self.callPackage ./vidcutter { };
      tasmota-decode-config = self.callPackage ./tasmota-decode-config { };

      jupyterlab_server = super.jupyterlab_server.overridePythonAttrs (old: {
        # TODO: rm when https://github.com/NixOS/nixpkgs/pull/179564 is merged
        preCheck = ''
          export HOME=$(mktemp -d)
        '';
      });
    };
  };

  ptsd-ffmpeg = self.ffmpeg-full.override {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
    qtFaststartProgram = false;
  };

  ptsd-nnn = (self.nnn.overrideAttrs (old: {
    makeFlags = old.makeFlags ++ [ "O_GITSTATUS=1" ];

    # fix for darwin, nnn assumes homebrew gsed
    patchPhase = ''
      substituteInPlace src/nnn.c --replace '#define SED "gsed"' '#define SED "${self.gnused}/bin/sed"'
    '';
  })).override
    { withNerdIcons = true; };

  ptsd-tesseract = self.tesseract.override { enableLanguages = [ "eng" "deu" ]; };

  firefox-bin = self.callPackage ./firefox-bin { };

  checkSSLCert = super.checkSSLCert.overrideAttrs (oldAttrs: rec {
    # TODO: waits for https://github.com/NixOS/nixpkgs/pull/147131
    version = "2.12.0";
    src = self.fetchFromGitHub {
      owner = "matteocorti";
      repo = "check_ssl_cert";
      rev = "v${version}";
      sha256 = "sha256-Y7NLCooMP78EesG9zivyuaHwl9qHY2GSOTKuHzYWj6c=";
    };
    patches = [ ];
  });

  logseq-bin = self.callPackage ./logseq-bin { };

  neovim-unwrapped = neovim-flake.packages.${self.system}.neovim;

  kanboard-plugin-google-auth = self.callPackage ./kanboard-plugin-google-auth { };

  pinephone-keyboard = self.callPackage ./pinephone-keyboard { };

  ptsd-vscode = self.vscode-with-extensions.override {
    vscodeExtensions = with self.vscode-extensions; [
      eamodio.gitlens
      editorconfig.editorconfig
      esbenp.prettier-vscode
      github.copilot
      golang.go
      hashicorp.terraform
      jkillian.custom-local-formatters
      jnoortheen.nix-ide
      ms-toolsai.jupyter
      ms-vscode-remote.remote-ssh
      #ms-vsliveshare.vsliveshare
    ] ++ self.lib.optionals (self.lib.elem self.stdenv.hostPlatform.system [ "x86_64-linux" ]) [
      ms-python.python
      ms-vscode.cpptools
    ];
  };

  linux-megi = self.callPackage ./linux-megi { };
  initvm = self.writeShellScriptBin "initvm" ''
    ${self.parted}/sbin/parted --script /dev/vda \
      mklabel gpt \
      mkpart "boot" fat32 1MiB 1000MiB \
      set 1 esp on \
      mkpart "nix" xfs 1000MiB 100%

    ${self.dosfstools}/bin/mkfs.vfat -n boot /dev/vda1 || exit 1
    ${self.xfsprogs}/bin/mkfs.xfs -f -L root /dev/vda2 || exit 1

    mount /dev/vda2 /mnt
    mkdir /mnt/boot
    mount /dev/vda1 /mnt/boot

    echo "nixos-install --flake github:elohmeier/ptsd#utmvm --no-channel-copy --no-root-password" > nixos-install.sh
    chmod +x nixos-install.sh
    echo "run ./nixos-install.sh to install"
  '';
  wordpress = self.callPackage ./wordpress { };

  xrdp = self.callPackage ./xrdp { };
  xorgxrdp = self.callPackage ./xrdp/xorgxrdp.nix { };

  borg2prom =
    let
      hostname = if self.stdenv.isDarwin then "/bin/hostname" else "${self.nettools}/bin/hostname";
    in
    self.writeShellScriptBin "borg2prom" ''
      set -e
      ARCHIVENAME="''${1?must provide ARCHIVENAME}"
      JOB_NAME="''${2?must provide JOB_NAME}"
      PATH=$PATH:${self.lib.makeBinPath [ self.borgbackup self.jq ]}
      . ${../4scripts/borg2prom.sh} "$ARCHIVENAME" "$JOB_NAME" | ${self.curl}/bin/curl -X PUT --data-binary @- "https://htz1.pug-coho.ts.net:9091/metrics/job/borgbackup/instance/$(${hostname} -s)→$JOB_NAME"
    '';

  prom-checktlsa = self.writeShellScriptBin "prom-checktlsa" ''
    PATH=$PATH:${self.lib.makeBinPath (with self; [ dig gawk glibc nettools bash checkSSLCert ])}
    . ${../4scripts/prom-checktlsa.sh}
  '';
}
