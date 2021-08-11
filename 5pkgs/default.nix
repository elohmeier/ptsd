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
  docker-machine-driver-hetzner = self.callPackage ./docker-machine-driver-hetzner { };
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
  pdfduplex = self.callPackage ./pdfduplex { };
  photoprism = self.callPackage ./photoprism { };
  ptsdbootstrap = self.callPackage ./ptsdbootstrap { };
  shrinkpdf = self.callPackage ./shrinkpdf { };
  swayassi = self.callPackage ./swayassi { };
  syncthing-device-id = self.callPackage ./syncthing-device-id { };
  telegram-sh = self.callPackage ./telegram-sh { };
  traefik-forward-auth = self.callPackage ./traefik-forward-auth { };
  tg = self.callPackage ./tg { };
  win10fonts = self.callPackage ./win10fonts { };
  wkhtmltopdf-qt4 = self.callPackage ./wkhtmltopdf-qt4 { };
  zathura-single = self.callPackage ./zathura-single { };

  ptsd-python3 = self.python3.override {
    packageOverrides = self: super: rec {
      black_nbconvert = self.callPackage ../5pkgs/black_nbconvert { };
      icloudpd = self.callPackage ../5pkgs/icloudpd { };
      nobbofin = self.callPackage ../5pkgs/nobbofin { };
      orgparse = self.callPackage ../5pkgs/orgparse { };
    };
  };

  ptsd-ffmpeg = self.ffmpeg-full.override {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
    qtFaststartProgram = false;
  };

  # pull in recent versions from >21.05
  foot = pkgs_master.foot;
  neovim = pkgs_master.neovim;
  neovim-unwrapped = pkgs_master.neovim-unwrapped;
  nushell = pkgs_master.nushell;
  vimPlugins = pkgs_master.vimPlugins;
  zoxide = pkgs_master.zoxide;
}
