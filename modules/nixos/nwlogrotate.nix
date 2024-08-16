{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ptsd.nwlogrotate;
in
{
  options = {
    ptsd.nwlogrotate = {
      config = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };

  config = mkIf (cfg.config != "") {

    systemd.services.nwlogrotate = {
      description = "logrotate service";
      wantedBy = [ "multi-user.target" ];
      startAt = "daily";

      serviceConfig = {
        ExecStart = "${pkgs.logrotate}/sbin/logrotate --state /var/lib/nwlogrotate/state ${pkgs.writeText "nwlogrotate.conf" cfg.config}";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        StateDirectory = "nwlogrotate";
        Restart = "no";
      };
    };

  };
}
