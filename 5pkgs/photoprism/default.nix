{ system, lib, stdenv, pkgs, nodejs, fetchFromGitHub, fetchurl, unzip, buildGoModule }:

let
  pname = "photoprism";
  version = "220121-2b4c8e1f"; # remember to update generate-dependencies.sh and run it

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-N8PhBQRFlMFbzmNFk77rMofMFgY7XNG+DRWUyhs2Pjw=";
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

  # tensorflow 1.15.x is required
  tf1_pkgs =
    let
      nixpkgs-rev = "34cb7885a61c344a22f262520186921843bc7636"; # release-20.09 as of 15.06.2021
    in
    import
      (builtins.fetchTarball {
        name = "nixpkgs-${nixpkgs-rev}";
        url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
        sha256 = "0fg3c76rdzaacybci046p4q1gzkj9s68virv4hbi6kfyn6k4cw11";
      })
      { inherit system; };
in
buildGoModule rec {
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

  vendorSha256 = "sha256-OLEoBLohZtHAQd2JUXX0jH2M0QBoB/0POoeOoChyYwY=";

  buildInputs = [
    # nas1 supports SSE4.2 (long build)
    # (tf1_pkgs.python37.pkgs.tensorflow_1.override {
    #   sse42Support = true; # nas1 supports SSE4.2 
    # }).libtensorflow

    # to use the cached binaries (faster)
    tf1_pkgs.python37.pkgs.tensorflow_1.libtensorflow
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
