{ config, lib, pkgs, ... }:
let
  desktopSecrets = import <secrets-shared/desktop.nix>;
in
{
  xsession.enable = true;

  imports = [
    <ptsd/3modules/home>
    <ptsd/2configs/home/git-alarm.nix>
  ];

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  ptsd.i3 = {
    enable = true;
  };

  ptsd.i3status-rust = {
    enable = true;
    openweathermapApiKey = desktopSecrets.openweathermapApiKey;
  };

  ptsd.pcmanfm.enable = true;

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
    keyboard = {
      layout = "de";
      variant = "nodeadkeys";
    };
    packages = with pkgs;
      [
        xorg.xev
        xorg.xhost
        gnome3.file-roller
        zathura
        zathura-single
        caffeine
        mpv
      ];
  };
}
