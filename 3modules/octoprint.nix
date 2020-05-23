{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.octoprint;

  baseConfig = {
    folder.logs = "/var/log/octoprint";
    plugins.curalegacy.cura_engine = "${pkgs.curaengine_stable}/bin/CuraEngine";
    server.host = cfg.host;
    server.port = cfg.port;
    webcam.ffmpeg = "${pkgs.ffmpeg.bin}/bin/ffmpeg";
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
        default = "0.0.0.0";
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
        default = plugins: [];
        defaultText = "plugins: []";
        example = literalExample "plugins: [ m3d-fio ]";
        description = "Additional plugins.";
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = {};
        description = "Extra options which are added to OctoPrint's YAML configuration file.";
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.octoprint = {
      description = "OctoPrint, web interface for 3D printers";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pluginsEnv ];

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
        PrivateDevices = "true";
        NoNewPrivileges = "true";
      };
    };
  };
}
