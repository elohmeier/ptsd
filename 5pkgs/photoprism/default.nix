{ system, lib, stdenv, pkgs, nodejs, fetchFromGitHub, fetchurl, unzip, buildGo118Module, tensorflow1 }:

let
  pname = "photoprism";
  version = "220528-efb5d710"; # remember to update generate-dependencies.sh and run it

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-mYFhw//Z5Vwek4kLItHBwK/HC1I7ZaEwGH4ZZMnRQ9I=";
  };

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  frontend = nodePackages.package.override {
    src = "${src}/frontend";
    NODE_ENV = "production";
    postInstall = ''
      # Patch shebangs in node_modules, otherwise the webpack build fails with interpreter problems
      patchShebangs --build "$out/lib/node_modules/photoprism/node_modules/"

      npm run build
    '';
  };
in
buildGo118Module rec {
  inherit pname version src;

  postPatch = ''
    rm -r docker
  '';

  srcNsfw = fetchurl {
    url = "https://dl.photoprism.org/tensorflow/nsfw.zip";
    sha256 = "sha256-615dIuN5YcMZKkdX7/+IP3e8mJwO/Oq7E5XglZ2WbxQ="; # up-to-date as of 2022-02-16
  };

  srcNasnet = fetchurl {
    url = "https://dl.photoprism.org/tensorflow/nasnet.zip";
    sha256 = "sha256-oOGtjVpaD/nvxLPtiYmL8AhWPuNsrNDIBKOE+PxmFYg="; # up-to-date as of 2022-02-16
  };

  srcFacenet = fetchurl {
    url = "https://dl.photoprism.org/tensorflow/facenet.zip";
    sha256 = "sha256-v5rglF0qxTrD2ycIIWLSud2luixWTA5MT1OfMfi2cK8="; # up-to-date as of 2022-02-16
  };

  vendorSha256 = "sha256-RLYMx14g7zM+j5jbvJPgh92lAv7IXJEsxNlpkXa+BMQ=";

  buildInputs = [
    tensorflow1
  ];

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  postInstall = ''
    cp -r assets $out/assets
    ${unzip}/bin/unzip $srcNsfw -d $out/assets
    ${unzip}/bin/unzip $srcNasnet -d $out/assets
    ${unzip}/bin/unzip $srcFacenet -d $out/assets
    cp -r ${frontend}/lib/node_modules/assets/static/build $out/assets/static/build
  '';

  doCheck = false;
}
