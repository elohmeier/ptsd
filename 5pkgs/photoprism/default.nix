# nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/photoprism { libtensorflow1-bin = callPackage ./5pkgs/tensorflow1 {}; }'

{ lib, stdenv, pkgs, nodejs, fetchFromGitHub, fetchurl, unzip, buildGoModule, libtensorflow1-bin }:

let
  pname = "photoprism";
  version = "210523-b1856b9d";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-zwx3kYIZXDuoy0hK54mHtwTzCpOWtxUoY24lpgC+cEU=";
  };

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  frontend = nodePackages.package.override {
    src = "${src}/frontend";
    NODE_ENV = "production";
    postInstall = ''
      # workaround wrong css font path resolution
      cp -r $out/lib/node_modules/photoprism/node_modules/material-design-icons-iconfont/dist/fonts $out/lib/node_modules/photoprism/src/css/fonts

      # Patch shebangs in node_modules, otherwise the webpack build fails with interpreter problems
      patchShebangs --build "$out/lib/node_modules/photoprism/node_modules/"

      npm run build
    '';
  };
in
buildGoModule rec {
  inherit pname version src;

  srcNasnet = fetchurl {
    url = "https://dl.photoprism.org/tensorflow/nasnet.zip";
    sha256 = "sha256-oOGtjVpaD/nvxLPtiYmL8AhWPuNsrNDIBKOE+PxmFYg=";
  };

  srcNsfw = fetchurl {
    url = "https://dl.photoprism.org/tensorflow/nsfw.zip";
    sha256 = "sha256-615dIuN5YcMZKkdX7/+IP3e8mJwO/Oq7E5XglZ2WbxQ=";
  };

  vendorSha256 = "sha256-bQes6lR2CMM8Oimi2C/5qrP0MNW2GUfwUiKzY5QhP8M=";

  buildInputs = [
    libtensorflow1-bin
  ];

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  postInstall = ''
    cp -r assets $out/assets
    ${unzip}/bin/unzip $srcNasnet -d $out/assets
    ${unzip}/bin/unzip $srcNsfw -d $out/assets
    cp -r ${frontend}/lib/node_modules/assets/static/build $out/assets/static/build
  '';

  doCheck = false;
}
