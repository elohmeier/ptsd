{ config, lib, pkgs, ... }:

let
  # just take the needed firmware files to reduce size
  firmware-rockchip = pkgs.runCommand "firmware-rockchip" { } ''          
          mkdir -p $out/lib/firmware
          ${pkgs.rsync}/bin/rsync -av ${pkgs.firmwareLinuxNonfree}/lib/firmware/{brcm,cypress,rockchip} $out/lib/firmware/
        '';
  firmware-bcm43 = pkgs.callPackage ./firmware-bcm43.nix { };
in
{
  hardware.firmware = with pkgs; [
    firmware-rockchip
    firmware-bcm43
  ];

  nixpkgs.config.packageOverrides = pkgs: pkgs.lib.recursiveUpdate pkgs {
    linuxKernel.kernels.linux_megi = pkgs.linuxKernel.manualConfig rec {
      inherit (pkgs) lib;

      stdenv = pkgs.stdenvAdapters.addAttrsToDerivation
        {
          # from https://wiki.gentoo.org/wiki/PINE64_ROCKPro64#GCC_optimization
          NIX_CFLAGS_COMPILE = [
            "-march=armv8-a+crc+crypto"
            "-mtune=cortex-a72.cortex-a53"
            "-mfix-cortex-a53-835769"
            "-mfix-cortex-a53-843419"
          ];
        }
        pkgs.stdenv;

      # config from postmarketos, see
      # https://gitlab.com/postmarketOS/pmaports/-/tree/master/device/testing/linux-pine64-pinephonepro
      configfile = ./config-pine64-pinephonepro.aarch64;

      version = "5.17.0-rc5";

      # prefetch sources remotely using
      # nix-shell -p git -p nix-prefetch-github --run "nix-prefetch-github --rev orange-pi-5.17-20220223-0235 megous linux"
      src = pkgs.fetchFromGitHub {
        owner = "megous";
        repo = "linux";
        rev = "orange-pi-5.17-20220223-0235";
        sha256 = "1pl6iwxrsm2lzmv97qdj3yr8wwmzfsqindczryd0xdx15ibdjdal";
      };
      allowImportFromDerivation = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_megi;

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  boot.initrd.availableKernelModules = [
    "gpu_sched"
    "dw_wdt"
    "fusb302"
    "panel_himax_hx8394"
    "goodix_ts"
    "kb151"
  ];

  # a lot of default modules are not included in our kconfig
  boot.initrd.includeDefaultModules = lib.mkForce false;

  boot.kernelParams = [
    "fw_devlink=off"
    "console=tty0"
    "console=ttyS2,115200n8"
    "fbcon=rotate:1"
  ];

  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
  console.keyMap = "us";
}
