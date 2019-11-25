{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwmonit;
  universe = import ../2configs/universe.nix;
  check-systemd-units = pkgs.writeShellScriptBin "check-systemd-units" ''
    set -e
    out=$(${pkgs.systemd}/bin/systemctl list-units --state=failed --all)
    echo $out
    if [[ $out == *"0 loaded units listed"* ]]; then
      exit 0
    else
      exit 1
    fi
  '';
  smtp_to_telegram = pkgs.callPackage ../5pkgs/smtp-to-telegram {};
in
{

  options = {
    ptsd.nwmonit = {
      enable = mkEnableOption "nwmonit";
      httpIP = mkOption {
        type = types.str;
        default = universe.nwvpn."${config.networking.hostName}".ip;
        example = "191.18.19.123";
      };
      httpUser = mkOption {
        type = types.str;
        default = "admin";
      };
      httpPassword = mkOption {
        type = types.str;
      };
      telegramBotToken = mkOption {
        type = types.str;
      };
      telegramChatIds = mkOption {
        type = types.str;
      };
      extraConfig = mkOption {
        type = with types; listOf str;
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ smtp_to_telegram ];

    users.users.smtp-to-telegram = {};

    systemd.services.monit = {
      requires = [ "smtp-to-telegram.service" ];
      after = [ "smtp-to-telegram.service" ];
    };

    systemd.services.smtp-to-telegram = {
      description = "STMP to Telegram Gateway";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${smtp_to_telegram}/bin/smtp_to_telegram";
        ExecStartPost = "${pkgs.coreutils}/bin/sleep 5"; # wait for smtp-to-telegram to come up
        User = "smtp-to-telegram";
        Restart = "on-failure";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "full";
      };
      environment = {
        ST_TELEGRAM_BOT_TOKEN = "${cfg.telegramBotToken}";
        ST_TELEGRAM_CHAT_IDS = "${cfg.telegramChatIds}";
        ST_TELEGRAM_MESSAGE_TEMPLATE = "{from}:\n\n{body}";
      };
    };

    services.monit = {
      enable = true;

      config = ''
        set daemon 30

        set alert enno@telegram

        set mailserver
          localhost
          port 2525
      
        set ssl {
          verify: enable
        }

        set tls {
          verify: enable
        }
      
        set httpd port 2812
          address ${cfg.httpIP}
          allow ${cfg.httpUser}:${cfg.httpPassword}
      
        check program check-systemd-units path ${check-systemd-units}/bin/check-systemd-units
          if status != 0 then alert
      
        check filesystem rootfs with path /
          if space usage > 80% then alert
          if inode usage > 80% then alert
      
        check system $HOST
          if loadavg (1min) per core > 2 for 15 cycles then alert
          if loadavg (5min) per core > 1.5 for 10 cycles then alert
          if loadavg (15min) per core > 1 for 8 cycles then alert
          if cpu usage > 90% for 10 cycles then alert
          if memory usage > 70% for 5 cycles then alert
          if swap usage > 20% for 10 cycles then alert
        ${lib.concatMapStrings (x: "\n${x}") cfg.extraConfig}        
      '';
    };
    networking.firewall.allowedTCPPorts = [ 2812 ];
  };
}
