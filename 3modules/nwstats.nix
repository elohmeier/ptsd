{ config, lib, pkgs, ... }:

with lib;

let
  gunicorn = pkgs.python3Packages.gunicorn;
  nwstats = pkgs.python3Packages.callPackage <ptsd/5pkgs/nwstats> {};
  python = pkgs.python3Packages.python;
  cfg = config.ptsd.nwstats;
  configFile = pkgs.writeText "nwstats.cfg" ''
    SECRET_KEY="${cfg.secretKey}"
    TODOIST_API_KEY="${cfg.todoistApiKey}"
    NOBBOFIN_PATH="${cfg.dataDir}/nobbofin"
    MAIL_HOSTNAME="imap.dd24.net"
    MAIL_INFO_USERNAME="info@nerdworks.de"
    MAIL_INFO_PASSWORD="${cfg.mailInfoPassword}"
    MAIL_ENNO_USERNAME="enno@nerdworks.de"
    MAIL_ENNO_PASSWORD="${cfg.mailEnnoPassword}"
  '';
in
{
  options = {
    ptsd.nwstats = {
      enable = mkEnableOption "nwstats";
      dataDir = mkOption {
        default = "/var/lib/nwstats";
        type = types.str;
        description = "nwstats data directory";
      };
      secretKey = mkOption {
        type = types.str;
      };
      todoistApiKey = mkOption {
        type = types.str;
      };
      mailEnnoPassword = mkOption {
        type = types.str;
      };
      mailInfoPassword = mkOption {
        type = types.str;
      };
      nobbofinUpdateInterval = mkOption {
        default = "2m";
        example = "1h";
        type = types.str;
        description = "When to perform a <command>nwstats-update-nobbofin</command> run (git pull). See <command>man 7 systemd.time</command> for the format.";
      };
    };
  };

  config = mkIf cfg.enable {

    users.users.nwstats = {
      description = "nwstats";
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
      group = "nwstats";
    };

    users.groups.nwstats = {};

    ptsd.secrets.files."nwstats.cfg" = {
      owner = "nwstats";
    };

    systemd.services.nwstats = {
      description = "nwstats HTTP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartIfChanged = true;

      environment = let
        penv = python.buildEnv.override {
          extraLibs = [ nwstats pkgs.python3Packages.setuptools ];
        };
      in
        {
          PYTHONPATH = "${penv}/${python.sitePackages}/";
          #NWSTATS_CONFIG = configFile;
          NWSTATS_CONFIG = config.ptsd.secrets.files."nwstats.cfg".path;
        };

      serviceConfig = {
        ExecStart = ''${gunicorn}/bin/gunicorn nwstats.wsgi \
            -u nwstats \
            -g nwstats \
            --workers 3 \
            --log-level info
          '';
        User = "nwstats";
        Group = "nwstats";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
      };
    };

    systemd.services.nwstats-update-nobbofin = {
      description = "nwstats: update nobbofin git repo";
      requires = [ "network.target" "network-online.target" ];
      after = [ "network.target" "network-online.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.git}/bin/git pull";
        User = "nwstats";
        Group = "nwstats";
        WorkingDirectory = "${cfg.dataDir}/nobbofin";
        Restart = "on-failure";
        RuntimeMaxSec = "300";
      };
    };

    systemd.timers.nwstats-update-nobbofin = {
      description = "Run nwstats-update-nobbofin every ${cfg.nobbofinUpdateInterval}";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2m";
        OnUnitInactiveSec = cfg.nobbofinUpdateInterval;
        Unit = "nwstats-update-nobbofin.service";
      };
    };

    environment.systemPackages = [ pkgs.git ];
  };
}
