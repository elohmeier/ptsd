{ config, lib, pkgs, ... }:
{
  ptsd.nwbackup = {
    cacheDir = "/persist/var/cache/borg";
    paths = [
      "/home"
      "/persist"
    ];
  };

  ptsd.secrets.files."nwbackup_id_ed25519" = {
    path = "/root/.ssh/id_ed25519";
  };

  ptsd.lego.home = "/persist/var/lib/lego";
}
