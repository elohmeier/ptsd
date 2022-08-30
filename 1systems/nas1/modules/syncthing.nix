{ config, lib, pkgs, ... }:

with lib;

let
  universe = import ../../../2configs/universe.nix;
in
{
  services.syncthing = {
    enable = true;

    key = "/var/src/secrets/syncthing.key";
    cert = "/var/src/secrets/syncthing.crt";
    devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);

    folders = {
      "/tank/enc/rawphotos/2021-06 mopedtour" = { label = "2021-06 mopedtour"; id = "ieyohHo7uang"; devices = [ "ext-arvid-laptop" "mb4" ]; };
      "/tank/enc/rawphotos/icloudpd" = { label = "icloudpd"; id = "myfag-uvj2s"; devices = [ "mb4" "rpi4" ]; };
    };
  };

  # syncthing might run a lengthy db migration
  systemd.services.syncthing-init.serviceConfig.TimeoutStartSec = "5min";
  systemd.services.syncthing.serviceConfig.TimeoutStartSec = "5min";

  boot.kernel.sysctl = {
    # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
    "fs.inotify.max_user_watches" = 204800;
  };
}
