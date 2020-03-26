{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    <ptsd/3modules>
  ];

  ptsd.nwtelegraf.enable = true;

  # Make sure zsh lands in /etc/shells
  # to not be affected by user not showing up in LightDM
  # as in https://discourse.nixos.org/t/normal-users-not-appearing-in-login-manager-lists/4619
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # as recommended in
  # https://github.com/rycee/home-manager/blob/master/modules/programs/zsh.nix
  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # will be socket-activated
  virtualisation.libvirtd.enable = true;

  ptsd.nwmonit.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    git
    gen-secrets
    syncthing-device-id
    nwvpn-qr
    redshift
    pavucontrol
    pasystray
    dunst
    libnotify
    gnupg
    paperkey
    home-manager
    lxqt.lxqt-policykit # provides a default authentification client for policykit
    nixpkgs-fmt
  ];
  services.gvfs.enable = true; # allow smb:// mounts in pcmanfm

  # open the syncthing ports
  # https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 21027 ];

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
    package = pkgs.pulseaudioFull; # for bluetooth
    support32Bit = true; # for Steam
  };
  hardware.firmware = [ pkgs.broadcom-bt-firmware ]; # for the plugable USB stick
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
  };

  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome3.gnome-keyring.enable = true;

  programs.xss-lock = let
    notify-pre-lock = pkgs.writeDash "notify-pre-lock" ''    
    ${pkgs.libnotify}/bin/notify-send "locking soon..."
  '';
  in
    {
      enable = true;
      lockerCommand = "${pkgs.nwlock}/bin/nwlock";
      extraOptions = [
        "-n"
        "${notify-pre-lock}"
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

  fonts.fonts = with pkgs; [ myfonts win10fonts roboto roboto-slab source-code-pro ];

  #services.teamviewer.enable = true;

  # for betaflight-configurator firmware flashing
  # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
  services.udev.extraRules = ''
    # DFU (Internal bootloader for STM32 MCUs)
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
  '';
}
