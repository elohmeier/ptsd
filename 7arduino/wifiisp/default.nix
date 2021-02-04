{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  name = "wifiisp";
  src = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ] ./.;

  deps = pkgs.stdenv.mkDerivation {
    name = "wifiisp-deps";
    src = ./platformio.ini;
    buildInputs = [ pkgs.platformio ];
    dontUnpack = true;
    installPhase = ''
      cp $src ./platformio.ini
      mkdir src
      echo "#include <SPI.h>" > src/fake.cpp
      mkdir -p $out
      PLATFORMIO_LIBDEPS_DIR=./pio/libdeps \
      PLATFORMIO_PACKAGES_DIR=./pio/packages \
      PLATFORMIO_PLATFORMS_DIR=./pio/platforms \
      pio run
      cp -r ./pio/* $out/
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "05ylj4s76r7yq23dvnkgyg30js12zwz1837343s4fi0pchh0whq8";
  };

  buildInputs = [ pkgs.platformio ];
  buildPhase = ''
    cp -r ${deps} ./pio/
    chmod -R 777 ./pio/
    echo ${deps}
    ls -l ${deps}
    ls -l ./
    ls -l ./pio
    PLATFORMIO_SETTING_AUTO_UPDATE_LIBRARIES=0 \
    PLATFORMIO_SETTING_AUTO_UPDATE_PLATFORMS=0 \
    PLATFORMIO_LIBDEPS_DIR=./pio/libdeps \
    PLATFORMIO_PLATFORMS_DIR=./pio/platforms \
    PLATFORMIO_PACKAGES_DIR=./pio/packages \
    pio run
  '';
}
