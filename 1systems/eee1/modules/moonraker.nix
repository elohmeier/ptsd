{ config, lib, pkgs, ... }:
{
  services.moonraker = {
    enable = true;
    settings = {
      server = {
        enable_debug_logging = true;
      };
      authorization = {
        trusted_clients = [ "127.0.0.1/32" "192.168.178.0/24" ];
        cors_domains = [ "http://eee1.fritz.box" ];
      };
    };
  };

  systemd.services.klipper.serviceConfig.UMask = "0012"; # allow group access to klipper api socket

  systemd.services.moonraker = {
    serviceConfig.SupplementaryGroups = "klipper";
  };
}
