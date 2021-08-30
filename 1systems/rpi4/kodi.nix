{ pkgs, ... }:

{
  services.cage = {
    enable = true;
    program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    user = "enno";
  };
}
