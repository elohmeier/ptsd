{ config, lib, pkgs, ... }:
{
  services.moonraker = {
    enable = true;
    settings = {
      server = {
        enable_debug_logging = false;
      };
      authorization = {
        trusted_clients = [ "127.0.0.1/32" "192.168.178.0/24" ];
        cors_domains = [ "http://eee1.fritz.box" ];
      };

      octoprint_compat = { }; # allow file upload from slicer
    };

    address = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ config.services.moonraker.port ];

  systemd.services.klipper.serviceConfig.UMask = "0012"; # allow group access to klipper api socket

  systemd.services.moonraker = {
    serviceConfig.SupplementaryGroups = "klipper";
    restartTriggers = [ (toString config.environment.etc."moonraker.cfg".source) ]; # restart on config change
  };
}
