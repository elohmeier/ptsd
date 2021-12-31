{ config, lib, pkgs, ... }:

{
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ config.services.octoprint.port ];

  fileSystems."/var/lib/octoprint" = {
    device = "/dev/sysVG/octoprint";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/var/lib/octoprint/generated" = {
    fsType = "tmpfs";
    options = [ "size=100M" "mode=1666" ];
  };

  fileSystems."/var/lib/octoprint/logs" = {
    fsType = "tmpfs";
    options = [ "size=100M" "mode=1666" ];
  };

  services.klipper.octoprintIntegration = true;

  services.octoprint = {
    enable = true;
    port = config.ptsd.nwtraefik.ports.octoprint;
    plugins = plugins:
      let
        ptsdPlugins = pkgs.ptsd-octoprintPlugins plugins;
      in
      [
        plugins.printtimegenius
        plugins.telegram
        plugins.curaenginelegacy
        plugins.gcodeeditor
        plugins.octoklipper
        ptsdPlugins.bedlevelvisualizer
        ptsdPlugins.m73progress
      ];
    extraConfig = {
      plugins = {
        _disabled = [
          "announcements"
          "tracking"
          "backup"
          "discovery"
          "errortracking"
          "firmware_check"
          "softwareupdate"
          "virtual_printer"
        ];
        bedlevelvisualizer.command = ''
          BED_MESH_CALIBRATE
          @BEDLEVELVISUALIZER
          BED_MESH_OUTPUT
        '';
        klipper = {
          configuration.configpath = "/etc/klipper.cfg";
          connection.port = "/run/klipper/tty";
        };
      };
      serial = {
        # recommended for klipper plugin
        disconnectOnErrors = false;

        # prevent octoprint timeouts
        longRunningCommands = [ "G4" "G28" "M400" "M226" "M600" "START_PRINT" ];
      };
      webcam = {
        stream = "http://eee1.nw/mjpg/?action=stream";
        snapshot = "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.mjpg-streamer}/?action=snapshot";
      };
    };
  };
}
