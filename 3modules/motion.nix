{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.motion;

  motionConfig = pkgs.writeText "motion.conf" (generators.toKeyValue { } {
    stream_port = cfg.streamPort;
    stream_localhost = "on"; # bind to localhost only
    video_device = cfg.videoDevice;
    target_dir = "/var/lib/motion";
    movie_output = "off"; # disable recording
  });
in
{
  options.ptsd.motion = {
    enable = mkEnableOption "motion";
    streamPort = mkOption {
      type = types.int;
      default = 8081;
    };
    videoDevice = mkOption {
      type = types.str;
      default = "/dev/video0";
    };
    hostName = mkOption {
      type = types.str;
      default = "localhost";
    };
  };

  config = mkIf cfg.enable {

    systemd.services.motion = {
      description = "Motion - software motion detection";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.motion}/bin/motion -c ${motionConfig}";
        Type = "simple";
        ExecReload = "@KILL@ -HUP $MAINPID";
        ProtectSystem = "full";
        ProtectHome = true;
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        DynamicUser = true;
        RestartPreventExitStatus = 78;
        RestartSec = 5;
        Restart = "on-failure";
        SupplementaryGroups = "video";
        StateDirectory = "motion";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.hostName} = {
        root = pkgs.motion-web;
        locations."/stream".extraConfig = ''
          proxy_pass http://127.0.0.1:${toString cfg.streamPort};
        '';
      };
    };

    environment.systemPackages = with pkgs;[ motion ];
  };
}
