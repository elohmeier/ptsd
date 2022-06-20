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
      "gpu_sched"
      "dw_wdt"
      "fusb302"
      "panel_himax_hx8394"
      "goodix_ts"
      "kb151"
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

  # https://xnux.eu/pinephone-keyboard/faq.html
  system.activationScripts.configure-pine-keyboard-charging = ''
    echo 1500000 > /sys/class/power_supply/rk818-usb/input_current_limit
  '';

  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
  console.keyMap = "us";

  environment.systemPackages = [ pkgs.pinephone-keyboard ];

  # todo: kernel module missing?
  networking.firewall.enable = false;
}
