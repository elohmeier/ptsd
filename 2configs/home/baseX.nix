{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home/baseX-minimal.nix>
    <ptsd/2configs/home/file-manager.nix>
    <ptsd/2configs/home/git-alarm.nix>
  ];

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
  };

  home.packages = with pkgs;
    [
      xorg.xev
      xorg.xhost
      gnome3.file-roller
      zathura
      zathura-single
      caffeine
      pcmanfm
      mpv
    ];

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };
}
