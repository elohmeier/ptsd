{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  imports = [
    ./bluetooth.nix
    ./fonts.nix
    ./gtk.nix
    ./i3compat.nix
    ./options.nix
    ./pipewire.nix
    ./rclone.nix
    ./sway.nix
  ];

  config = mkIf (cfg.enable && !config.ptsd.bootstrap) {

    ptsd.secrets.files."hass-cli.env" = mkIf cfg.waybar.co2 {
      owner = config.users.users.mainUser.name;
    };
    ptsd.secrets.files.baresip-accounts = mkIf cfg.baresip.enable {
      owner = config.users.users.mainUser.name;
    };
    ptsd.secrets.files."fraam-gdrive-backup-3b42c04ff1ec.json" = mkIf cfg.rclone.enable {
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

    security.polkit.enable = mkDefault true;

    environment.variables = {
      PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
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

    programs.wireshark.enable = true;
    users.groups.wireshark.members = [ config.users.users.mainUser.name ];

    home-manager =
      {
        users.mainUser = { config, nixosConfig, pkgs, ... }:
          {
            imports = [
              ../home
              ./baresip.nix
              ./waybar.nix
              ./xdg.nix
              ../../2configs/home/fish.nix
            ];

            programs.foot = {
              enable = true;
              settings = {
                main = {
                  font = lib.mkDefault "${cfg.fontMono}:size=${toString cfg.fontSize}";
                  dpi-aware = lib.mkDefault "no";
                };
                scrollback.lines = 50000;
              };
            };

            home.keyboard = {
              layout = lib.mkDefault "de";
              variant = "nodeadkeys";
            };

            # home.file = {
            #   ".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
            # };
          };
      };
  };
}
