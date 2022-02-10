{ config, lib, pkgs, ... }:

{
  hardware.firmware = with pkgs; [ firmwareLinuxNonfree ];

  nixpkgs.config.packageOverrides = pkgs: pkgs.lib.recursiveUpdate pkgs {
    linuxKernel.kernels.linux_megi = pkgs.linuxKernel.manualConfig rec {
      inherit (pkgs) stdenv lib;

      # config from postmarketos, see
      # https://gitlab.com/postmarketOS/pmaports/-/tree/master/device/testing/linux-pine64-pinephonepro
      configfile = ./config-pine64-pinephonepro.aarch64;

      version = "5.16.7";

      # prefetch sources remotely using
      # nix-shell -p git -p nix-prefetch-github --run "nix-prefetch-github --rev orange-pi-5.16-20220205-1958 megous linux"
      src = pkgs.fetchFromGitHub {
        owner = "megous";
        repo = "linux";
        rev = "orange-pi-5.16-20220205-1958";
        sha256 = "sha256-X5lg1lVzidEV0DnfkPOy9BHm02doM6gTdsJnwUhOvbc=";
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
  ];

  # a lot of default modules are not included in our kconfig
  boot.initrd.includeDefaultModules = false;

  boot.kernelParams = [
    "fw_devlink=off"
    "console=tty0"
    "console=ttyS2,115200n8"
  ];
}
