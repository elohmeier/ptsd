{ config, lib, pkgs, ... }:
{
  imports = [
    <ptsd>
    <ptsd/2configs/audio.nix>
    <ptsd/2configs/baseX-minimal.nix>
    <ptsd/2configs/bluetooth.nix>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/zsh-enable.nix>
    <ptsd/3modules>
  ];

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = true;
  };
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome3.gnome-keyring.enable = true;

  # required for evolution
  programs.dconf.enable = true;
  systemd.packages = [ pkgs.gnome3.evolution-data-server ];

  environment.systemPackages = with pkgs; [
    git
    zstd # can be removed in 20.09 (default there)
    gen-secrets
    syncthing-device-id
    nwvpn-qr
    redshift
    dunst
    libnotify
    gnupg
    paperkey
    lxqt.lxqt-policykit # provides a default authentification client for policykit
    nixpkgs-fmt
    lm_sensors

    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science

    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large

    (writeTextFile {
      name = "drawio-mimetype";
      text = ''
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="application/vnd.jgraph.mxfile">
            <comment>draw.io Diagram</comment>
            <glob pattern="*.drawio" case-sensitive="true"/>
          </mime-type>
        </mime-info>
      '';
      destination = "/share/mime/packages/drawio.xml";
    })
  ];
  services.gvfs.enable = true; # allow smb:// mounts in pcmanfm

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  systemd.user.services.redshift = {
    description = "Screen color temperature manager";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.redshift}/bin/redshift";
      RestartSec = 3;
      Restart = "on-failure";
    };
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
    cozette
    iosevka
    nwfonts
    proggyfonts
    roboto
    roboto-slab
    source-code-pro
    win10fonts

    # required by nwi3status
    font-awesome_5
    material-design-icons
    typicons
  ];

  # for betaflight-configurator firmware flashing
  # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
  services.udev.extraRules = ''
    # DFU (Internal bootloader for STM32 MCUs)
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
  '';

  services.upower.enable = true;
  services.lorri.enable = true;
}
