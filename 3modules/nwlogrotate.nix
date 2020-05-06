{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwlogrotate;
  logrotateConfig = pkgs.writeText "logrotate.conf" ''
    ${lib.concatMapStrings (x: "\n${x}") cfg.configs}
  '';
in
{
  options = {
    ptsd.nwlogrotate = {
      configs = mkOption {
        type = with types; listOf str;
        default = [];
      };
    };
  };

  config = mkIf (cfg.configs != []) {

    systemd.services.logrotate = {
      description = "logrotate service";
      wantedBy = [ "multi-user.target" ];
      startAt = "daily";

      serviceConfig = {
        ExecStart = "${pkgs.logrotate}/sbin/logrotate --state /var/lib/logrotate/state ${logrotateConfig}";
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
