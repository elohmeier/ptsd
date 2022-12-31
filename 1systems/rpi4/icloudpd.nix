{ config, lib, pkgs, ... }:

let
  user = "syncthing";
  group = "syncthing";
in
{
  ptsd.icloudpd.jobs = {
    enno = {
      inherit user group;
      directory = "/var/lib/syncthing/photos/originals/icloudpd/enno";
      envFile = "/var/lib/syncthing/icloudpd-enno.env";
      cookieDirectory = "/var/lib/syncthing/icloudpd-cookies";
    };

    luisa = {
      inherit user group;
      directory = "/var/lib/syncthing/photos/originals/icloudpd/luisa";
      envFile = "/var/lib/syncthing/icloudpd-luisa.env";
      cookieDirectory = "/var/lib/syncthing/icloudpd-cookies";
    };
  };
}
