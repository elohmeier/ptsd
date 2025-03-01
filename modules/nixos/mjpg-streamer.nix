{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ptsd.mjpg-streamer;
  outputPlugin =
    builtins.replaceStrings
      [ "@www@" ]
      [
        "${cfg.package}/share/mjpg-streamer/www"
      ]
      cfg.outputPlugin;
in
{
  options = {
    ptsd.mjpg-streamer = {
      enable = mkEnableOption "mjpg-streamer webcam streamer";
      package = mkOption {
        default = pkgs.mjpg-streamer;
        type = types.package;
      };

      inputPlugin = mkOption {
        type = types.str;
        default = "input_uvc.so";
        example = "input_uvc.so -f 30 -r 1920x1080";
        description = ''
          Input plugin. See plugins documentation for more information.
        '';
      };

      outputPlugin = mkOption {
        type = types.str;
        default = "output_http.so -w @www@ -n -p 5050";
        description = ''
          Output plugin. <literal>@www@</literal> is substituted for default mjpg-streamer www directory.
          See plugins documentation for more information.
        '';
      };

      deviceService = mkOption {
        default = "";
        type = types.str;
        description = "hot-plug start service";
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.mjpg-streamer = {
      description = "mjpg-streamer webcam streamer";
      after = [ "network.target" ];
      wantedBy = if cfg.deviceService == "" then [ "multi-user.target" ] else [ cfg.deviceService ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mjpg_streamer -i '${cfg.inputPlugin}' -o '${outputPlugin}'";
        DynamicUser = true;
        Restart = "on-failure";
        PrivateTmp = "true";
        ProtectSystem = "full";
        ProtectHome = "true";
        NoNewPrivileges = "true";
        SupplementaryGroups = "video";
        CPUWeight = 20;
      };
    } // lib.optionalAttrs (cfg.deviceService != "") { bindsTo = [ cfg.deviceService ]; };
  };
}
