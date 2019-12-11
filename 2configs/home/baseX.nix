{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
  zathura-single = pkgs.writeShellScriptBin "zathura-single" ''
    ${pkgs.killall}/bin/killall zathura 2>/dev/null
    ${pkgs.zathura}/bin/zathura "$*"
  '';

in
{
  xsession.enable = true;

  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
  };

  ptsd.i3 = {
    enable = true;
  };

  ptsd.urxvt.enable = true;

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
  };

  home.packages = with pkgs; [
    (wineStaging.override { wineBuild = "wine32"; })

    slack-dark

    unstable.jetbrains.pycharm-professional
    unstable.vscodium
    sqlitebrowser
    filezilla
    libreoffice
    inkscape
    gimp
    tor-browser-bundle-bin
    spotify
    xournalpp
    calibre
    unstable.xmind
    transmission-gtk

    chromium

    thunderbird
    sylpheed

    unstable.zoom-us

    pulseeffects

    mucommander
    xorg.xev
    xorg.xhost

    gnome3.file-roller
    zathura
    zathura-single
    nerdworks-motivation
    caffeine
    lguf-brightness

    nitrokey-app
    yubioath-desktop
    yubikey-manager-qt
    keepassxc
    xcalib

  ];

  # fix font antialiasing in mucommander
  home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };
}
