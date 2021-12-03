{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwsyncthing;
  universe = import ../2configs/universe.nix;
in
{
  options = {
    ptsd.nwsyncthing = {
      enable = mkEnableOption "nwsyncthing";
      folders = mkOption {
        type = types.attrs;
      };
    };
  };

  config = mkIf cfg.enable {

    ptsd.secrets.files = {
      "syncthing.key" = {
        dependants = [ "syncthing.service" ];
      };
      "syncthing.crt" = {
        dependants = [ "syncthing.service" ];
      };
    };

    services.syncthing = {
      enable = true;
      user = "enno";
      group = "users";
      configDir = "/home/enno/.config/syncthing";
      dataDir = "/home/enno/";

      key = "/run/keys/syncthing.key";
      cert = "/run/keys/syncthing.crt";
      devices = mapAttrs (_: hostcfg: hostcfg.syncthing) (filterAttrs (_: hostcfg: hasAttr "syncthing" hostcfg) universe.hosts);
      folders = cfg.folders;
    };

    # open the syncthing ports
    # https://docs.syncthing.net/users/firewall.html
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 21027 ];
  };
}
