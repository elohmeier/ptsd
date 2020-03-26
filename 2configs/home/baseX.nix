{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home/file-manager.nix>
  ];

  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
  };

  ptsd.urxvt.enable = true;

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
  };

  home.packages = with pkgs;
    [
      unstable.vscodium
      xorg.xev
      xorg.xhost
      gnome3.file-roller
      zathura
      zathura-single
      caffeine
      lguf-brightness
      pcmanfm
      vlc
    ];

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };
}
