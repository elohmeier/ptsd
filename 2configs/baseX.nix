{ config, lib, pkgs, ... }:
{
  imports = [
    <ptsd>
    <ptsd/2configs/audio.nix>
    <ptsd/2configs/baseX-minimal.nix>
    <ptsd/2configs/bluetooth.nix>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    <ptsd/2configs/zsh-enable.nix>
    <ptsd/3modules>
  ];

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = true;
  };
  security.pam.services.lightdm.enableGnomeKeyring = true;

  services.dbus.packages = [ pkgs.gnome3.dconf ];
  services.gnome3.gnome-keyring.enable = true;

  ptsd.nwmonit.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    git
    zstd # can be removed in 20.09 (default there)
    gen-secrets
    syncthing-device-id
    nwvpn-qr
    redshift
    pavucontrol
    pasystray
    (
      pulseaudio-dlna.override {
        pulseaudio = pulseaudio;
      }
    )
    dunst
    libnotify
    gnupg
    paperkey
    lxqt.lxqt-policykit # provides a default authentification client for policykit
    nixpkgs-fmt
    lm_sensors
  ];
  services.gvfs.enable = true; # allow smb:// mounts in pcmanfm

  # disabled to be able to use linuxPackages_latest
  # boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];


  systemd.user.services.redshift = {
    description = "Screen color temperature manager";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.redshift}/bin/redshift";
      RestartSec = 3;
      Restart = "always";
    };
  };

  systemd.user.services.flameshot = {
    description = "Screenshot Tool";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.flameshot}/bin/flameshot";
      RestartSec = 3;
      Restart = "always";
    };
  };


  hardware.logitech = {
    enable = true;
    enableGraphical = true;
  };

  # yubikey
  services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  hardware.nitrokey = {
    enable = true;
  };

  users.groups.nitrokey.members = [ config.users.users.mainUser.name ];
  users.groups.keys.members = [ config.users.users.mainUser.name ];

  fonts.fonts = with pkgs; [
    iosevka
    myfonts
    roboto
    roboto-slab
    source-code-pro
    win10fonts

    # required by i3status-rs
    font-awesome_5
  ];

  # for betaflight-configurator firmware flashing
  # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
  services.udev.extraRules = ''
    # DFU (Internal bootloader for STM32 MCUs)
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
  '';

  services.upower.enable = true;
}
