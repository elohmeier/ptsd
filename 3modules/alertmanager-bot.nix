{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.alertmanager-bot;
in
{
  options = {
    ptsd.alertmanager-bot = {
      enable = mkEnableOption "alertmanager-bot";
      package = mkOption {
        type = types.package;
        default = pkgs.alertmanager-bot;
        defaultText = "pkgs.alertmanager-bot";
      };
      envFile = mkOption {
        type = types.path;
      };
      alertmanagerUrl = mkOption {
        type = types.str;
        default = config.services.prometheus.alertmanager.webExternalUrl;
      };
      listenAddress = mkOption {
        type = types.str;
      };
      templatePath = mkOption {
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.alertmanager-bot = {
      description = "Telegram bot for Prometheus Alertmanager";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = ''${pkgs.alertmanager-bot}/bin/alertmanager-bot \
        --alertmanager.url="${cfg.alertmanagerUrl}" --log.level=info \
        --store=bolt --bolt.path=/var/lib/alertmanager-bot/bot.db \
        --listen.addr="${cfg.listenAddress}" \
          --template.paths="${cfg.templatePath}"'';
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateDevices = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        AmbientCapabilities = "cap_net_bind_service";
        NoNewPrivileges = true;
        DynamicUser = true;
        StateDirectory = "alertmanager-bot";
        Restart = "on-failure";
        EnvironmentFile = cfg.envFile;
      };
    };
  };
}
