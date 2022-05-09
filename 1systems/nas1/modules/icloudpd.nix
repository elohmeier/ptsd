{ config, lib, pkgs, ... }:

let
  user = "syncthing";
  group = "syncthing";
in
{
  ptsd.icloudpd.jobs = {
    enno = {
      inherit user group;
      directory = "/tank/enc/rawphotos/photos/icloudpd-enno";
      envFile = "/var/src/secrets/icloudpd-enno.env";
    };

    luisa = {
      inherit user group;
      directory = "/tank/enc/rawphotos/photos/icloudpd-luisa";
      envFile = "/var/src/secrets/icloudpd-luisa.env";
    };
  };
}
