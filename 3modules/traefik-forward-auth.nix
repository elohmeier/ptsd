{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.traefik-forward-auth;
in
{
  options = {
    ptsd.traefik-forward-auth = {
      enable = mkEnableOption "traefik-forward-auth";

      package = mkOption {
        type = types.package;
        default = pkgs.traefik-forward-auth;
        defaultText = "pkgs.traefik-forward-auth";
      };

      envFile = mkOption {
        type = types.path;
      };

      env = mkOption {
        type = types.attrs;
        default = {};
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.traefik-forward-auth = {
      description = "Traefik forward authentication service";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/cmd";
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateDevices = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        AmbientCapabilities = "cap_net_bind_service";
        NoNewPrivileges = true;
        DynamicUser = true;
        #StateDirectory = "traefik-forward-auth"; # not needed?
        Restart = "on-failure";
        EnvironmentFile = cfg.envFile;
        ReadOnlyPaths = cfg.envFile;
      };
      environment = {
        LOG_LEVEL = "warn";
      } // cfg.env;
    };

  };
}
