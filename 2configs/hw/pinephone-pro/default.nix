{ config, lib, pkgs, ... }:

let
  firmware-bcm43 = pkgs.callPackage ./firmware-bcm43.nix { };
in
{
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
    firmware-bcm43
  ];

  nixpkgs.config.packageOverrides = pkgs: pkgs.lib.recursiveUpdate pkgs {
    linuxKernel.kernels.linux_megi = pkgs.linuxKernel.manualConfig rec {
      inherit (pkgs) stdenv lib;

      # config from postmarketos, see
      # https://gitlab.com/postmarketOS/pmaports/-/tree/master/device/testing/linux-pine64-pinephonepro
      configfile = ./config-pine64-pinephonepro.aarch64;

      version = "5.17.0-rc3";

      # prefetch sources remotely using
      # nix-shell -p git -p nix-prefetch-github --run "nix-prefetch-github --rev orange-pi-5.17-20220210-0212 megous linux"
      src = pkgs.fetchFromGitHub {
        owner = "megous";
        repo = "linux";
        rev = "orange-pi-5.17-20220210-0212";
        sha256 = "134m6x087bjc25scn61cymva8xxnkb7a6bcrld66gaj9vq73fnwj";
      };
      allowImportFromDerivation = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_megi;

  boot.initrd.availableKernelModules = [
    "gpu_sched"
    "dw_wdt"
    "fusb302"
    "panel_himax_hx8394"
    "goodix_ts"
    "kb151"
  ];

  # a lot of default modules are not included in our kconfig
  boot.initrd.includeDefaultModules = false;

  boot.kernelParams = [
    "fw_devlink=off"
    "console=tty0"
    "console=ttyS2,115200n8"
    "fbcon=rotate:1"
  ];

  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
}
