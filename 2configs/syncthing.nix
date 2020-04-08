{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "enno";
    group = "users";
    configDir = "/home/enno/.config/syncthing";
    dataDir = "/home/enno/";
  };

  # open the syncthing ports
  # https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 21027 ];
}
