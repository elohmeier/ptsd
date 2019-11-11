# Status: Work-in-Progress



{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.vdi-container;
  xephyrWrapper = pkgs.writeShellScriptBin "${cfg.containerName}-xephyr" ''
    ${pkgs.xorg.xorgserver}/bin/Xephyr \
      -resizeable \
      -br \
      -ac \
      -noreset \
      -screen 1920x1080 \
      -extension MIT-SHM -extension XTEST \
      -nolisten tcp \
      -keybd ephyr,xkbmodel=evdev,xkblayout='de(nodeadkeys)' \
      ${cfg.xephyrDisplayId}
  '';
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
      default = "my-vdi";
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
    xephyrDisplayId = mkOption {
      type = types.str;
      default = ":1";
    };
    startupUrls = mkOption {
      type = types.listOf (types.str);
      description = "URLs Firefox should open automatically after startup, e.g. Login web page for Firewalls etc.";
      default = [];
    };
  };

  config = mkIf cfg.enable {

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = cfg.extIf;
      };

      extraHosts = ''
        ${cfg.containerAddress} ${cfg.containerName}
      '';
    };

    environment.systemPackages = [ xephyrWrapper ];

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

            environment.variables = {
              DISPLAY = cfg.xephyrDisplayId;
              ICEWM_PRIVCFG = "/etc/X11/icewm";
            };

            environment.etc."X11/icewm/startup" = {
              text = ''
                ${pkgs.firefox}/bin/firefox \
                  --no-remote \
                  ${lib.concatMapStrings (x: " \"${x}\"") cfg.startupUrls}
              '';
              mode = "0755";
            };

            networking = {
              useHostResolvConf = false;
              nameservers = [ "8.8.8.8" "8.8.4.4" ]; # will be used for VPN DNS lookup
            };
          };
    };


  };
}
