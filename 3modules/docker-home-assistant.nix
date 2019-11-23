{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.dockerHomeAssistant;
in
{
  options = {
    ptsd.dockerHomeAssistant = {
      enable = mkEnableOption "dockerHomeAssistant";
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ 8123 ];

    # guessed port range for pyHomematic XML RPC Server
    networking.firewall.allowedTCPPortRanges = [ { from = 30000; to = 39999; } ];

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
        homeassistant/home-assistant:0.99.3 \
      '';
        ExecStop = "${pkgs.docker}/bin/docker stop home-assistant";
        ExecReload = "${pkgs.docker}/bin/docker restart home-assistant";
        TimeoutStartSec = 300; # protect slow docker pulls
      };
    };

  };
}
