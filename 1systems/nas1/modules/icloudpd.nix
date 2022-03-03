{ config, lib, pkgs, ... }:

let
  user = "nextcloud";
  group = "nginx";
in
{
  ptsd.icloudpd.jobs = {
    enno = {
      inherit user group;
      directory = "/tank/enc/rawphotos/photos/icloudpd";
      envFile = "/var/src/secrets/icloudpd.env";
    };

    # TODO
    # luisa = {
    #   inherit user group;
    # };
  };
}
