{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
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
  ];

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };
}
