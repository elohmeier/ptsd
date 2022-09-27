{ config, lib, pkgs, ... }:

with lib;
let
  universe = import ../../../2configs/universe.nix;
in
{
  services.syncthing = {
    enable = true;
    user = "enno";
    group = "users";
    configDir = "/home/enno/.config/syncthing";
    dataDir = "/home/enno/";

    key = "/home/enno/.keys/syncthing.key";
    cert = "/home/enno/.keys/syncthing.crt";
    devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hasAttr "syncthing") universe.hosts);
    folders = {
      "/home/enno/repos" = {
        id = "yqa69-2zjmt";
        devices = [ "nas1" "mb4" ];
        label = "repos";
        ignorePerms = false;
      };
    };
  };

  # manual start
  systemd.services.syncthing.wantedBy = mkForce [ ];
  systemd.services.syncthing-init.wantedBy = mkForce [ ];

  # open the syncthing ports
  # https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 21027 ];
}
