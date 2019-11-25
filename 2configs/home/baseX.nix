{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
  xmind = pkgs.callPackage ./pkgs/xmind {};
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
    xmind
    transmission-gtk

    chromium
    firefox

    thunderbird
    sylpheed

    unstable.zoom-us

    pulseeffects
  ];
}
