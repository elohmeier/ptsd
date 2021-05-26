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
self: super:
{
  acme-dns = self.callPackage ./acme-dns { };
  art = self.callPackage ./art { };
  fritzbox-exporter = self.callPackage ./fritzbox-exporter { };
  gen-secrets = self.callPackage ./gen-secrets { };
  hashPassword = self.callPackage ./hashPassword { };
  hidclient = self.callPackage ./hidclient { };
  home-assistant-variants = self.callPackage ./home-assistant-variants { };
  httpserve = self.callPackage ./httpserve { };
  kitty-terminfo = self.callPackage ./kitty-terminfo { };
  monica = self.callPackage ./monica { };
  nbconvert = self.callPackage ./nbconvert { };
  nerdworks-artwork = self.callPackage ./nerdworks-artwork { };
  nwbackup-env = self.callPackage ./nwbackup-env { };
  nwfonts = self.callPackage ./nwfonts { };
  nwvpn-qr = self.callPackage ./nwvpn-qr { };
  pdfduplex = self.callPackage ./pdfduplex { };
  shrinkpdf = self.callPackage ./shrinkpdf { };
  syncthing-device-id = self.callPackage ./syncthing-device-id { };
  telegram-sh = self.callPackage ./telegram-sh { };
  tg = self.callPackage ./tg { };
  vims = self.callPackage ./vims { };
  win10fonts = self.callPackage ./win10fonts { };
  zathura-single = self.callPackage ./zathura-single { };
}
