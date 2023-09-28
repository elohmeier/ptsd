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
    linuxKernel.kernels.linux_megi = pkgs.callPackage ../../../5pkgs/linux-megi { };
  };

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_megi;

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  boot.initrd = {
    availableKernelModules = [
      "dw_wdt"
      "fusb302"
      "goodix_ts"
      "gpu_sched"
      "panel_himax_hx8394"
      "pinephone-keyboard"
    ];
    kernelModules = [
      "dm_mod" # for lvm
    ];
  };

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

  environment.systemPackages = with pkgs; [ brightnessctl pinephone-keyboard ];

  # todo: kernel module missing?
  networking.firewall.enable = false;
}
