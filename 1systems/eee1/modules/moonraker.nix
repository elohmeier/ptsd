{ config, lib, pkgs, ... }:
{
  services.moonraker = {
    enable = true;
    settings = {
      server = {
        enable_debug_logging = false;
      };
      authorization = {
        trusted_clients = [ "127.0.0.1/32" ];
        cors_domains = [ "http://eee1.fritz.box" ];
      };
    };
  };

  systemd.services.klipper.serviceConfig.UMask = "0012"; # allow group access to klipper api socket

  systemd.services.moonraker = {
    serviceConfig.SupplementaryGroups = "klipper";
    documentation = [ (toString config.environment.etc."moonraker.cfg".source) ]; # ensure moonraker restart on config change
  };
}
