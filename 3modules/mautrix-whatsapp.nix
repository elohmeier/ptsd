{ config, lib, pkgs, ... }:

with lib;

let
  dataDir = "/var/lib/mautrix-whatsapp";
  cfg = config.ptsd.mautrix-whatsapp;
  settingsFormat = pkgs.formats.json { };
  settingsFileUnsubstituted = settingsFormat.generate "mautrix-whatsapp-config-unsubstituted.json" cfg.settings;
  settingsFile = "${dataDir}/config.json";
in
{
  options = {
    ptsd.mautrix-whatsapp = {
      enable = mkEnableOption "mautrix-whatsapp";

      # see https://github.com/tulir/mautrix-whatsapp/blob/master/example-config.yaml
      settings = mkOption rec {
        apply = recursiveUpdate default;
        inherit (settingsFormat) type;
        default = {
          appservice = {
            hostname = "0.0.0.0";
            port = 29318;
            address = "http://localhost:${toString port}";
            database = {
              type = "sqlite3";
              uri = "mautrix-whatsapp.db";
            };
            id = "whatsapp";
            bot = {
              username = "whatsappbot";
              displayname = "";
            };
          };
          metrics = {
            enabled = false;
          };
          whatsapp = {
            os_name = "MWABR";
            browser_name = "IE";
          };
          bridge = { };
          logging = {
            directory = "/var/log/mautrix-whatsapp";
            file_name_format = "{{.Date}}-{{.Index}}.log";
            file_date_format = "2006-01-02";
            file_mode = "0600";
            timestamp_format = "Jan _2, 2006 15:04:05";
            print_level = "debug";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {

    # see https://docs.mau.fi/bridges/go/whatsapp/setup/systemd.html
    systemd.services.mautrix-whatsapp = {
      description = "mautrix-whatsapp bridge";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.mautrix-whatsapp}/bin/mautrix-whatsapp -c ${settingsFile}";

        Type = "exec";
        DynamicUser = true;
        WorkingDirectory = "/var/lib/mautrix-whatsapp";
        StateDirectory = "mautrix-whatsapp";
        LoggingDirectory = "mautrix-whatsapp";
        Restart = "on-failure";
        RestartSec = 30;

        NoNewPrivileges = "yes";
        MemoryDenyWriteExecute = true;
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        ProtectHome = "yes";
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        PrivateUsers = true;
        ProtectClock = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
      };
    };

  };
}
