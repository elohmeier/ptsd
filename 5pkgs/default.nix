self: pkgs_master: nixpkgs_master:neovim-flake: super:
{
  acme-dns = self.callPackage ./acme-dns { };
  art = self.callPackage ./art { };
  add-workspace =
    self.writers.writePython3
      "add-workspace"
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
  betaflight-configurator = pkgs_master.betaflight-configurator.overrideAttrs
    (old: {
      version = "10.8.0-RC3";
      src = self.fetchurl {
        url = "https://github.com/betaflight/betaflight-configurator/releases/download/10.8.0-RC3/betaflight-configurator_10.8.0_linux64-portable.zip";
        sha256 = "sha256-iOfwS0xD87fcepKG7TW9Crrk2JkZWUnIBY/jgh9m4so=";
      };
    });
  carberryd = self.callPackage ./carberryd { };
  choose-browser = self.writers.writeDashBin "choose-browser" ../4scripts/choose-browser.sh;
  docker-machine-driver-hetzner = self.callPackage ./docker-machine-driver-hetzner { };
  file-renamer = self.writers.writePython3 "file-renamer" { } ../4scripts/file-renamer.py;
  firefox-mobile = self.callPackage ./firefox-mobile { };
  fraam-update-static-web = self.callPackage ./fraam-update-static-web { };
  fritzbox-exporter = self.callPackage ./fritzbox-exporter { };
  gen-secrets = self.callPackage ./gen-secrets { };
  gomumblesoundboard = self.callPackage ./gomumblesoundboard { };
  gowpcontactform = self.callPackage ./gowpcontactform { };
  hashPassword = self.callPackage ./hashPassword { };
  hidclient = self.callPackage ./hidclient { };
  home-assistant-variants = self.callPackage ./home-assistant-variants { };
  kitty-terminfo = self.callPackage ./kitty-terminfo { };
  firefox-config-desktop = self.callPackage ./firefox-configs/desktop.nix { wrapFirefox = self.callPackage ./firefox-configs/wrapper.nix { }; };
  firefox-config-mobile = self.callPackage ./firefox-configs/mobile.nix { };
  lz4json = self.callPackage ./lz4json { };
  monica = self.callPackage ./monica { };
  motion-web = self.callPackage ./motion-web { };
  nbconvert = self.callPackage ./nbconvert { };
  nerdworks-artwork = self.callPackage ./nerdworks-artwork { };
  nwbackup-env = self.callPackage ./nwbackup-env { };
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
  sxmo-utils = self.callPackage ./sxmo-utils { };
  syncthing-device-id = self.callPackage ./syncthing-device-id { };
  telegram-sh = self.callPackage ./telegram-sh { };
  traefik-forward-auth = self.callPackage ./traefik-forward-auth { };
  tg = self.callPackage ./tg { };
  win10fonts = self.callPackage ./win10fonts { };
  wkhtmltopdf-qt4 = self.callPackage ./wkhtmltopdf-qt4 { };
  wvkbd = self.callPackage ./wvkbd { };
  zathura-single = self.callPackage ./zathura-single { };

  ptsd-fishPlugins = {
    hydro = self.callPackage ./fish-plugins/hydro.nix { };
  };

  ptsd-octoprintPlugins = plugins: {
    bedlevelvisualizer = plugins.callPackage ./octoprint-plugins/bedlevelvisualizer.nix { };
    bltouch = plugins.callPackage ./octoprint-plugins/bltouch.nix { };
    firmwareupdater = plugins.callPackage ./octoprint-plugins/firmwareupdater.nix { };
    m73progress = plugins.callPackage ./octoprint-plugins/m73progress.nix { };
    octolapse = plugins.callPackage ./octoprint-plugins/octolapse.nix { };
    prusalevelingguide = plugins.callPackage ./octoprint-plugins/prusalevelingguide.nix { };
    prusaslicerthumbnails = plugins.callPackage ./octoprint-plugins/prusaslicerthumbnails.nix { };
  };

  ptsd-python2 = self.python2.override {
    packageOverrides = pyself: pysuper: rec {
      certifi = pysuper.buildPythonPackage rec {
        pname = "certifi";
        version = "2020.04.05.1"; # last version with python2 support
        src = self.fetchFromGitHub {
          owner = pname;
          repo = "python-certifi";
          rev = version;
          sha256 = "sha256-scdb86Bg5tTUDwm5OZ8HXar7VCNlbPMtt4ZzGu/2O4w=";
        };
      };
    };
  };

  ptsd-py2env = self.ptsd-python2.withPackages (pythonPackages: with pythonPackages; [ impacket pycrypto requests ]);

  ptsd-python3 = self.python3.override {
    packageOverrides = self: super: rec {
      black = super.black.overrideAttrs (old: {
        # support reformatting ipynb files
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.ipython super.tokenize-rt ];
      });
      bloodhound-import = self.callPackage ../5pkgs/bloodhound-import { };
      davphonebook = self.callPackage ../5pkgs/davphonebook { };
      finance-dl = self.callPackage ../5pkgs/finance-dl { };
      icloudpd = self.callPackage ../5pkgs/icloudpd { };
      neo4j-driver = self.callPackage ../5pkgs/neo4j-driver { };
      nobbofin = self.callPackage ../5pkgs/nobbofin { };
      orgparse = self.callPackage ../5pkgs/orgparse { };
      postgrest-py = self.callPackage ../5pkgs/postgrest-py { };
      pyxlsb = self.callPackage ../5pkgs/pyxlsb { };
      selenium-requests = self.callPackage ../5pkgs/selenium-requests { };
      vidcutter = self.callPackage ./vidcutter { };

      # pull in some newer versions
      cmd2 = self.callPackage "${nixpkgs_master}/pkgs/development/python-modules/cmd2" { };
      httpcore = self.callPackage "${nixpkgs_master}/pkgs/development/python-modules/httpcore" { };
      httpx = self.callPackage "${nixpkgs_master}/pkgs/development/python-modules/httpx" { };
      pydantic = self.callPackage "${nixpkgs_master}/pkgs/development/python-modules/pydantic" { };
      socksio = self.callPackage "${nixpkgs_master}/pkgs/development/python-modules/socksio" { };
    };
  };

  ptsd-py3env = self.ptsd-python3.withPackages (
    pythonPackages: with pythonPackages; [
      authlib
      beancount
      black
      bloodhound-import
      holidays
      i3ipc
      # todo: add https://github.com/corps/nix-kernel/blob/master/nix-kernel/kernel.py
      jupyterlab
      lxml
      keyring
      nbconvert
      pandas
      pdfminer
      pillow
      requests
      selenium
      tabulate
      orgparse
      weasyprint
      beautifulsoup4
      pytest
      mypy
      isort
      nobbofin
      sshtunnel
      mysql-connector
      boto3
      impacket
      pycrypto
      pylint
      pyxlsb
      psycopg2
      faker
      netifaces

      # faraday-cli frix port
      arrow
      cmd2
      faraday-plugins
      termcolor
      postgrest-py
    ]
  );


  ptsd-ffmpeg = self.ffmpeg-full.override {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
    qtFaststartProgram = false;
  };

  ptsd-nnn = (self.nnn.overrideAttrs (old: {
    makeFlags = old.makeFlags ++ [ "O_GITSTATUS=1" ];
  })).override
    { withNerdIcons = true; };

  ptsd-firefoxAddons = import ./firefox-addons { callPackage = self.callPackage; };

  ptsd-tesseract = self.tesseract.override { enableLanguages = [ "eng" "deu" ]; };

  # pull in recent versions from >21.11
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

  klipper = super.klipper.overrideAttrs (oldAttrs: {
    version = pkgs_master.klipper.version;
    src = pkgs_master.klipper.src;
  });

  baresip = pkgs_master.baresip;
  libre = pkgs_master.libre;
  librem = pkgs_master.librem;
  vimPlugins = pkgs_master.vimPlugins;
  neovim-unwrapped = neovim-flake.packages.${self.system}.neovim;

  btop = pkgs_master.btop;
  mepo = pkgs_master.mepo;
  nix-top = pkgs_master.nix-top;

  sway = pkgs_master.sway;
  wlroots = pkgs_master.wlroots;

  kanboard = pkgs_master.kanboard.overrideAttrs (old: {
    src = self.fetchFromGitHub {
      owner = "kanboard";
      repo = "kanboard";
      rev = "v1.2.22";
      sha256 = "sha256-WG2lTPpRG9KQpRdb+cS7CqF4ZDV7JZ8XtNqAI6eVzm0=";
    };
  });
  kanboard-plugin-google-auth = self.callPackage ./kanboard-plugin-google-auth { };

  flameshot = pkgs_master.flameshot;

  # required for systemd-socket-activation (to be released in foot v1.12)
  foot = pkgs_master.foot.overrideAttrs (oldAttrs: {
    version = "2022-03-19";
    src = self.fetchFromGitea {
      domain = "codeberg.org";
      owner = "dnkl";
      repo = "foot";
      rev = "de5226c93007c588f28a12215796c462a05e5bdf";
      sha256 = "sha256-ykbv9lpWxS89W8W+cWrEuxLP6osPf+BOdueYLUdLkwY=";
    };
  });
  jless = pkgs_master.jless;

  pinephone-keyboard = self.callPackage ./pinephone-keyboard { };

  vscode = pkgs_master.vscode;
  vscode-with-extensions = pkgs_master.vscode-with-extensions;
  vscode-extensions = pkgs_master.vscode-extensions;

  ptsd-vscode = pkgs_master.vscode-with-extensions.override {
    vscodeExtensions = with pkgs_master.vscode-extensions; [
      eamodio.gitlens
      editorconfig.editorconfig
      esbenp.prettier-vscode
      github.copilot
      golang.go
      hashicorp.terraform
      jkillian.custom-local-formatters
      jnoortheen.nix-ide
      ms-python.python
      ms-toolsai.jupyter
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools
      ms-vsliveshare.vsliveshare
    ];
  };

  logseq = pkgs_master.logseq;
  httpie = pkgs_master.httpie;
  yt-dlp = pkgs_master.yt-dlp;
}
