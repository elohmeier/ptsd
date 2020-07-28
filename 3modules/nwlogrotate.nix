{ config, lib, pkgs, ... }:

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

    systemd.services.logrotate = {
      description = "logrotate service";
      wantedBy = [ "multi-user.target" ];
      startAt = "daily";

      serviceConfig = {
        ExecStart = "${pkgs.logrotate}/sbin/logrotate --state /var/lib/logrotate/state ${pkgs.writeText "logrotate.conf" cfg.config}";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        StateDirectory = "logrotate";
        Restart = "no";
      };
    };

  };
}
