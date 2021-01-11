{ config, lib, pkgs, ... }:
let
  desktopSecrets = import <secrets-shared/desktop.nix>;
  todoistSecrets = import <secrets/todoist.nix>;
in
{
  imports = [
    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  ptsd.sway = {
    enable = true;
    screenshotCommand = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
  };

  ptsd.nwi3status = {
    enable = true;
    openweathermapApiKey = desktopSecrets.openweathermapApiKey;
  };

  home.packages = [
    pkgs.qt5.qtwayland
  ];
  home.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
