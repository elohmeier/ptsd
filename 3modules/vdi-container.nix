# Status: Work-in-Progress



{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.vdi-container;
in
{
  options.ptsd.vdi-container = {
    enable = mkEnableOption "vdi-container: containerized AnyConnect VPN / Citrix VDI setup";
    extIf = mkOption {
      type = types.str;
      default = "eth0";
      description = "external network interface container traffic will be NATed over";
    };
    containerName = mkOption {
      type = types.str;
    };
    containerAddress = mkOption {
      type = types.str;
      default = "192.168.100.12";
      description = "IP address of the container in the private host/container-network";
    };
    hostAddress = mkOption {
      type = types.str;
      default = "192.168.100.10";
      description = "IP address of the host in the private host/container-network";
    };
  };

  config = mkIf cfg.enable {

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterfaces = cfg.extIf;
      };

      extraHosts = ''
        ${cfg.containerAddress} ${cfg.containerName}
      '';
    };

    containers."${cfg.containerName}" = {
      autoStart = true;
      enableTun = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = {
        "/tmp/.X11-unix" = {
          hostPath = "/tmp/.X11-unix";
          isReadOnly = true; # X11 clients won't need write access
        };
      };

      config =
        { config, pkgs, ... }:
          {
            boot.isContainer = true;
          };
    };


  };
}
