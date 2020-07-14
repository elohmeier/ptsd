{ config, lib, pkgs, ... }:

let
  # pulseAudioFull required for bluetooth audio support
  pulseaudio = (
    pkgs.pulseaudioFull.overrideAttrs (
      old: {
        patches = [
          # mitigate https://pulseaudio-bugs.freedesktop.narkive.com/RfIRytly/pulseaudio-tickets-bug-96819-new-module-echo-cancel-aec-method-webrtc-parsing-mic-geometry-value-is-
          ./patches/echo-cancel-make-webrtc-beamforming-parameter-parsing-locale-independent.patch
        ];
      }
    )
  ).override {
    airtunesSupport = true;
  };
in
{
  imports = [
    <ptsd>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    <ptsd/3modules>
  ];

  # Make sure zsh lands in /etc/shells
  # to not be affected by user not showing up in LightDM
  # as in https://discourse.nixos.org/t/normal-users-not-appearing-in-login-manager-lists/4619
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # as recommended in
  # https://github.com/rycee/home-manager/blob/master/modules/programs/zsh.nix
  environment.pathsToLink = [ "/share/zsh" ];

  ptsd.nwmonit.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    git
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

  systemd.user.services.pasystray = {
    description = "PulseAudio system tray";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [ pkgs.pavucontrol ];
    serviceConfig = {
      # Workaround from https://github.com/NixOS/nixpkgs/issues/7329 to make GTK-Themes work
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.pasystray}/bin/pasystray'";
      RestartSec = 3;
      Restart = "always";
    };
  };

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

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pulseaudio;
    support32Bit = true; # for Steam

    # better audio quality settings
    # from https://medium.com/@gamunu/enable-high-quality-audio-on-linux-6f16f3fe7e1f
    daemon.config = {

      default-sample-format = "float32le";
      default-sample-rate = lib.mkDefault 48000;
      alternate-sample-rate = 44100;
      default-sample-channels = 2;
      default-channel-map = "front-left,front-right";
      resample-method = "speex-float-10";
      enable-lfe-remixing = "no";
      high-priority = "yes";
      nice-level = -11;
      realtime-scheduling = "yes";
      realtime-priority = 9;
      rlimit-rtprio = 9;
    };
  };
  services.blueman.enable = true;

  # improved version of the pkgs.blueman-provided user service
  systemd.user.services.blueman-applet-nw = {
    description = "Bluetooth management applet";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      # Workaround from https://github.com/NixOS/nixpkgs/issues/7329 to make GTK-Themes work
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.blueman}/bin/blueman-applet'";
      RestartSec = 3;
      Restart = "always";
    };
  };

  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.gnome3.dconf ];

  services.xserver = {
    enable = true;
    layout = "de";

    libinput = {
      enable = true;
      clickMethod = "clickfinger";
      naturalScrolling = true;
    };

    desktopManager.xterm.enable = true;
  };

  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome3.gnome-keyring.enable = true;

  programs.xss-lock =
    {
      enable = true;
      lockerCommand = "${pkgs.nwlock}/bin/nwlock";
      extraOptions = [
        "-n"
        "${pkgs.nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
        "-l" # make sure not to allow machine suspend before the screen saver is active
      ];
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
