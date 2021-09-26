# self: super:
# with super.lib;
# let
#   eq = x: y: x == y;
#   subdirsOf = path:
#     mapAttrs
#       (name: _: path + "/${name}")
#       (filterAttrs (_: eq "directory") (builtins.readDir path));
# in
# mapAttrs
#   (_: flip self.callPackage { })
#   (
#     filterAttrs
#       (_: dir: pathExists (dir + "/default.nix"))
#       (subdirsOf ./.)
#   )
# left for illustrative purposes
#  // {
# inherit (self.callPackage ./hasura {})
#   hasura-cli
#   hasura-graphql-engine
# };
self: pkgs_master: super:
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
  carberryd = self.callPackage ./carberryd { };
  docker-machine-driver-hetzner = self.callPackage ./docker-machine-driver-hetzner { };
  file-renamer = self.writers.writePython3 "file-renamer" { } ../4scripts/file-renamer.py;
  fraam-update-static-web = self.callPackage ./fraam-update-static-web { };
  fritzbox-exporter = self.callPackage ./fritzbox-exporter { };
  gen-secrets = self.callPackage ./gen-secrets { };
  gowpcontactform = self.callPackage ./gowpcontactform { };
  hashPassword = self.callPackage ./hashPassword { };
  hidclient = self.callPackage ./hidclient { };
  home-assistant-variants = self.callPackage ./home-assistant-variants { };
  kitty-terminfo = self.callPackage ./kitty-terminfo { };
  monica = self.callPackage ./monica { };
  nbconvert = self.callPackage ./nbconvert { };
  nerdworks-artwork = self.callPackage ./nerdworks-artwork { };
  nwbackup-env = self.callPackage ./nwbackup-env { };
  nwfonts = self.callPackage ./nwfonts { };
  nwvpn-qr = self.callPackage ./nwvpn-qr { };
  pdfconcat = self.writers.writePython3 "pdfconcat"
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
  read-co2-status = self.writeShellScriptBin "read-co2-status" ../4scripts/read-co2-status.sh;
  read-battery-status = self.writeShellScriptBin "read-battery-status" ../4scripts/read-battery-status.sh;
  shrinkpdf = self.callPackage ./shrinkpdf { };
  swayassi = self.callPackage ./swayassi { };
  syncthing-device-id = self.callPackage ./syncthing-device-id { };
  telegram-sh = self.callPackage ./telegram-sh { };
  traefik-forward-auth = self.callPackage ./traefik-forward-auth { };
  tg = self.callPackage ./tg { };
  win10fonts = self.callPackage ./win10fonts { };
  wkhtmltopdf-qt4 = self.callPackage ./wkhtmltopdf-qt4 { };
  zathura-single = self.callPackage ./zathura-single { };

  ptsd-octoprintPlugins = plugins: {
    bedlevelvisualizer = plugins.callPackage ./octoprint-plugins/bedlevelvisualizer.nix { };
    bltouch = plugins.callPackage ./octoprint-plugins/bltouch.nix { };
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
      black_nbconvert = self.callPackage ../5pkgs/black_nbconvert { };
      bloodhound-import = self.callPackage ../5pkgs/bloodhound-import { };
      davphonebook = self.callPackage ../5pkgs/davphonebook { };
      icloudpd = self.callPackage ../5pkgs/icloudpd { };
      neo4j-driver = self.callPackage ../5pkgs/neo4j-driver { };
      nobbofin = self.callPackage ../5pkgs/nobbofin { };
      orgparse = self.callPackage ../5pkgs/orgparse { };
    };
  };

  ptsd-py3env = self.ptsd-python3.withPackages (
    pythonPackages: with pythonPackages; [
      authlib
      beancount
      black
      black_nbconvert
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
    ]
  );

  ptsd-ffmpeg = self.ffmpeg-full.override {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
    qtFaststartProgram = false;
  };

  ptsd-neovim-small = self.callPackage ./ptsd-neovim {
    enableLSP = false;
    enableFormatters = false;
  };

  ptsd-neovim-full = self.callPackage ./ptsd-neovim { };

  ptsd-nnn = self.nnn.override { withNerdIcons = true; };

  ptsd-vscodium = self.vscodium.overrideAttrs (oldAttrs: {
    postInstall = ''
      makeWrapper $out/bin/codium $out/bin/codium-wayland --add-flags " --enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
  });

  ptsd-firefoxAddons = import ./firefox-addons { callPackage = self.callPackage; };

  # pull in recent versions from >21.05
  wrapFirefox = pkgs_master.wrapFirefox;
  firefox-esr = pkgs_master.firefox-esr;
  firefox-esr-wayland = pkgs_master.firefox-esr-wayland;
  firefox-esr-unwrapped = pkgs_master.firefox-esr-unwrapped;
  foot = pkgs_master.foot;
  neovim = pkgs_master.neovim;
  neovim-unwrapped = pkgs_master.neovim-unwrapped;
  neovimUtils = pkgs_master.neovimUtils;
  wrapNeovimUnstable = pkgs_master.wrapNeovimUnstable;
  nushell = pkgs_master.nushell;
  vimPlugins = pkgs_master.vimPlugins;
  zoxide = pkgs_master.zoxide;
}
