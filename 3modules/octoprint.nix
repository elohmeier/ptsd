{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.octoprint;

  baseConfig = {
    folder.logs = "/var/log/octoprint";
    plugins.curalegacy.cura_engine = "${pkgs.curaengine_stable}/bin/CuraEngine";
    server.host = cfg.host;
    server.port = cfg.port;
    webcam = {
      ffmpeg = "${pkgs.ffmpeg.bin}/bin/ffmpeg";
    } // lib.optionalAttrs (cfg.webcamStreamUrl != "") {
      stream = cfg.webcamStreamUrl;
    } // lib.optionalAttrs (cfg.webcamSnapshotUrl != "") {
      snapshot = cfg.webcamSnapshotUrl;
    };
  };

  fullConfig = recursiveUpdate cfg.extraConfig baseConfig;

  cfgUpdate = pkgs.writeText "octoprint-config.yaml" (builtins.toJSON fullConfig);

  pluginsEnv = cfg.package.python.withPackages (ps: [ ps.octoprint ] ++ (cfg.plugins ps));

  stateDir = "/var/lib/octoprint"; # created by systemd-StateDirectory
in
{
  options = {
    ptsd.octoprint = {
      enable = mkEnableOption "OctoPrint, web interface for 3D printers";
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Host to bind OctoPrint to.
        '';
      };
      port = mkOption {
        type = types.int;
        default = 5000;
        description = ''
          Port to bind OctoPrint to.
        '';
      };
      package = mkOption {
        default = pkgs.octoprint;
        type = types.package;
      };
      plugins = mkOption {
        default = plugins: [ ];
        defaultText = "plugins: []";
        example = literalExpression "plugins: [ m3d-fio ]";
        description = "Additional plugins.";
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        description = "Extra options which are added to OctoPrint's YAML configuration file.";
      };
      serialDevice = mkOption {
        default = "/dev/ttyUSB0";
        type = types.str;
      };
      deviceService = mkOption {
        default = "";
        type = types.str;
        description = "hot-plug start service";
      };
      webcamStreamUrl = mkOption {
        default = "";
        type = types.str;
      };
      webcamSnapshotUrl = mkOption {
        default = "";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.octoprint = {
      description = "OctoPrint, web interface for 3D printers";
      after = [ "network.target" cfg.deviceService ];
      wantedBy = if cfg.deviceService == "" then [ "multi-user.target" ] else [ cfg.deviceService ];
      path = [
        pluginsEnv

        # Telegram plugin requirements for /gif functionality
        pkgs.cpulimit
        pkgs.ffmpeg
      ];
      preStart = ''
        if [ -e "${stateDir}/config.yaml" ]; then
          ${pkgs.yaml-merge}/bin/yaml-merge "${stateDir}/config.yaml" "${cfgUpdate}" > "${stateDir}/config.yaml.tmp"
          mv "${stateDir}/config.yaml.tmp" "${stateDir}/config.yaml"
        else
          cp "${cfgUpdate}" "${stateDir}/config.yaml"
          chmod 600 "${stateDir}/config.yaml"
        fi
      '';
      serviceConfig = {
        ExecStart = "${pluginsEnv}/bin/octoprint serve -b ${stateDir}";
        DynamicUser = true;
        LogsDirectory = "octoprint";
        StateDirectory = "octoprint";
        Restart = "on-failure";
        PrivateTmp = "true";
        ProtectSystem = "full";
        ProtectHome = "true";
        NoNewPrivileges = "true";
        DeviceAllow = "${cfg.serialDevice} rw";
        SupplementaryGroups = "dialout";
      };
      restartIfChanged = false;
    } // lib.optionalAttrs (cfg.deviceService != "") {
      bindsTo = [ cfg.deviceService ];
    };

    # size restrict tmp directory to mitigate timelapse jpeg errors
    fileSystems."/var/lib/private/octoprint/timelapse/tmp" = {
      fsType = "tmpfs";
      options = [ "size=500M" "mode=1777" ];
    };
  };
}
