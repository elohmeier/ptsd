{ config, lib, pkgs, ... }:

let
  defaults = {
    "force group" = "syncthing";
    "force user" = "syncthing";
    "guest ok" = "no";
    "read only" = "no";
    browseable = "no";
  };
in
{
  services.samba = {
    enable = true;
    shares.scans-enno = defaults // { path = "/tank/enc/enno/Scans"; };
    shares.scans-luisa = defaults // { path = "/tank/enc/luisa/Scans"; };
  };
}
