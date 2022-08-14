{ linuxKernel, lib, stdenv, stdenvAdapters, fetchFromGitHub, ... }:

let
  stdenvRockPro64 = stdenvAdapters.addAttrsToDerivation
    {
      # from https://wiki.gentoo.org/wiki/PINE64_ROCKPro64#GCC_optimization
      NIX_CFLAGS_COMPILE = [
        "-march=armv8-a+crc+crypto"
        "-mtune=cortex-a72.cortex-a53"
        "-mfix-cortex-a53-835769"
        "-mfix-cortex-a53-843419"
      ];
    }
    stdenv;
in
linuxKernel.manualConfig rec {
  inherit lib;

  stdenv = stdenvRockPro64;

  # config from postmarketos, see
  # https://gitlab.com/postmarketOS/pmaports/-/tree/ppp-community/device/community/linux-pine64-pinephonepro
  configfile = ./config-pine64-pinephonepro.aarch64;

  version = "5.19.0";

  # prefetch sources remotely using
  # nix-shell -p git -p nix-prefetch-github --run "nix-prefetch-github --rev orange-pi-5.17-20220313-2345 megous linux"
  src = fetchFromGitHub {
    owner = "megous";
    repo = "linux";
    rev = "orange-pi-5.19-20220802-0940";
    sha256 = "sha256-oz1vmq2ooDhb+Yalk9XrkO3eq2pGcjFiHTSXR7L29yU=";
  };
  allowImportFromDerivation = true;
}
