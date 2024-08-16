{ config, pkgs, ... }:

{
  services.octoprint = {
    enable = true;
    host = "127.0.0.1";
    port = config.ptsd.ports.octoprint;
    plugins =
      plugins:
      let
        ptsdPlugins = pkgs.ptsd-octoprintPlugins plugins;
      in
      [
        plugins.curaenginelegacy
        plugins.octolapse
        plugins.printtimegenius
        ptsdPlugins.firmwareupdater
        ptsdPlugins.prusalevelingguide
        ptsdPlugins.prusaslicerthumbnails
      ];

    extraConfig = {
      api.allowCrossOrigin = true; # mandatory for reverse proxy
      folder = {
        logs = "/var/log/octoprint";
        timelapse = "/var/cache/octoprint/timelapse";
        timelapse_tmp = "/var/cache/octoprint/timelapse/tmp";
        uploads = "/var/cache/octoprint/uploads";
        watched = "/var/cache/octoprint/watched";
      };
      plugins = {
        pi_support.vcgencmd_throttle_check_command = "${pkgs.libraspberrypi}/bin/vcgencmd get_throttled";
        firmwareupdater = {
          _selected_profile = 0;
          profiles = [
            {
              # prusa config
              _name = "Default";
              flash_method = "avrdude";
              avrdude_avrmcu = "m2560";
              avrdude_path = "${pkgs.avrdude}/bin/avrdude";
              avrdude_programmer = "wiring";
              serial_port = "/dev/ttyACM0";
            }
          ];
        };
        tracking.enabled = false;
      };
      server = {
        firstRun = false;
        onlineCheck.enabled = false;
        pluginBlacklist.enabled = false;
      };
      webcam = {
        snapshot = "https://${config.ptsd.tailscale.fqdn}:5000/cam/snapshot";
        stream = "https://${config.ptsd.tailscale.fqdn}:5000/cam/stream";
      };
    };
  };

  systemd.services.octoprint.serviceConfig = {
    CacheDirectory = "octoprint";
    LogsDirectory = "octoprint";
    SupplementaryGroups = [ "video" ];
  };

  services.nginx.virtualHosts.octoprint.locations = {
    "/".extraConfig = "client_max_body_size 100M;"; # allow large uploads
    "/cam/".extraConfig = "proxy_pass http://127.0.0.1:${toString config.ptsd.ports.ustreamer}/;";
  };

  systemd.services.ustreamer = {
    description = "ustreamer webcam stream";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ustreamer}/bin/ustreamer --device /dev/video0 --host 127.0.0.1 --port=${toString config.ptsd.ports.ustreamer}";
      DynamicUser = true;
      SupplementaryGroups = [ "video" ];
    };
  };
}
