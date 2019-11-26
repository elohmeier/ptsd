{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.dockerHomeAssistant;
in
{
  options = {
    ptsd.dockerHomeAssistant = {
      enable = mkEnableOption "dockerHomeAssistant";
      version = mkOption {
        default = "0.102.2";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ 8123 ];

    # guessed port range for pyHomematic XML RPC Server
    networking.firewall.allowedTCPPortRanges = [ { from = 30000; to = 49999; } ];

    virtualisation.docker.enable = true;

    systemd.services."home-assistant" = {
      description = "Home-Assistant (Docker)";
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];
      serviceConfig = {
        ExecStart = ''${pkgs.docker}/bin/docker run \
        --name home-assistant --rm \
        -v /var/lib/hass-docker:/config \
        -v /etc/localtime:/etc/localtime:ro \
        --net=host \
        homeassistant/home-assistant:${cfg.version} \
      '';
        ExecStop = "${pkgs.docker}/bin/docker stop home-assistant";
        ExecReload = "${pkgs.docker}/bin/docker restart home-assistant";
        TimeoutStartSec = 300; # protect slow docker pulls
      };
    };

  };
}
