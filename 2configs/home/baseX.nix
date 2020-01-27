{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
in
{
  imports = [
    <ptsd/2configs/home/file-manager.nix>
  ];

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

  home.packages = with pkgs; let
    wine = wineStaging.override { wineBuild = "wine32"; };
  in
    [
      wine
      (winetricks.override { wine = wine; })

      slack-dark

      unstable.jetbrains.pycharm-professional
      unstable.vscodium
      sqlitebrowser
      #filezilla
      libreoffice
      inkscape
      gimp
      #tor-browser-bundle-bin
      spotify
      xournalpp
      calibre
      unstable.xmind
      transmission-gtk

      chromium

      #thunderbird
      sylpheed

      #unstable.zoom-us

      pulseeffects

      #mucommander
      xorg.xev
      xorg.xhost

      gnome3.file-roller
      zathura
      zathura-single
      #nerdworks-motivation
      caffeine
      lguf-brightness

      #nitrokey-app
      #yubioath-desktop
      #yubikey-manager-qt
      keepassxc
      xcalib

      portfolio

      unstable.steam

      woeusb
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
