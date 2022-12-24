{ config, lib, pkgs, ... }:

let
  user = "syncthing";
  group = "syncthing";
in
{
  ptsd.icloudpd.jobs = {
    enno = {
      inherit user group;
      directory = "/mnt/syncthing/icloudpd/enno";
      envFile = "/mnt/syncthing/icloudpd-enno.env";
      cookieDirectory = "/mnt/syncthing/icloudpd-cookies";
    };

    luisa = {
      inherit user group;
      directory = "/mnt/syncthing/icloudpd/luisa";
      envFile = "/mnt/syncthing/icloudpd-luisa.env";
      cookieDirectory = "/mnt/syncthing/icloudpd-cookies";
    };
  };
}
