{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  imports = [
    ./bluetooth.nix
    ./gtk.nix
    ./i3compat.nix
    ./options.nix
    ./pipewire.nix
    ./sway.nix
    ./theme.nix
  ];

  config = mkIf cfg.enable {

    ptsd.secrets.files."hass-cli.env" = mkIf cfg.waybar.co2 {
      owner = config.users.users.mainUser.name;
    };
    ptsd.secrets.files.baresip-accounts = mkIf cfg.baresip.enable {
      owner = config.users.users.mainUser.name;
    };

    security.sudo = {
      extraConfig = ''
        # disable sudo warning
        Defaults lecture=never
      '';
      extraRules = lib.mkAfter [
        {
          users = [ config.users.users.mainUser.name ];
          commands = [
            { command = "${config.nix.package}/bin/nix-collect-garbage"; options = [ "NOPASSWD" ]; }
            { command = "${pkgs.iftop}/bin/iftop"; options = [ "NOPASSWD" ]; }
          ];
        }
      ];
    };

    programs.browserpass.enable = true;

    # speed up networking
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr"; # affects both IPv4 and IPv6r

    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
      extraPortals = with pkgs;[ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    };

    boot.supportedFilesystems = [
      "exfat" # canon sd card
      "nfs"
    ];
    system.fsPackages = [ pkgs.ntfs3g ];

    services.dbus.packages = [ pkgs.gcr ]; # for pinentry-gnome3 for gnupg

    environment.variables = {
      TERMINAL = cfg.term.binary;
    };

    environment.systemPackages = with pkgs; [
      bemenu
      cfg.term.package
      libinput
      libnotify
      brightnessctl
      pciutils
    ];

    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # yubikey
    services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    hardware.nitrokey = {
      enable = true;
    };

    users.groups.nitrokey.members = [ config.users.users.mainUser.name ];
    users.groups.keys.members = [ config.users.users.mainUser.name ];

    # for betaflight-configurator firmware flashing
    # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
    services.udev.extraRules = ''
      # DFU (Internal bootloader for STM32 MCUs)
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
    '';

    services.upower.enable = true;

  };
}
