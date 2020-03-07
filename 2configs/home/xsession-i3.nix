{ config, lib, pkgs, ... }:

{
  xsession.enable = true;

  imports = [
    <ptsd/2configs/home/file-manager.nix>
    <ptsd/2configs/home/git-alarm.nix>
  ];

  ptsd.i3 = {
    enable = true;
  };

  home.packages = with pkgs;
    [
      sxiv # image viewer
      lxmenu-data # pcmanfm: show "installed applications"
      shared_mime_info # pcmanfm: recognise different file types
    ];

}
