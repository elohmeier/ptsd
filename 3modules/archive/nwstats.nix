{ config, lib, pkgs, ... }:

with lib;
let
  gunicorn = pkgs.python3Packages.gunicorn;
  nwstats = pkgs.python3Packages.callPackage <ptsd/5pkgs/nwstats> { };
  python = pkgs.python3Packages.python;
  cfg = config.ptsd.nwstats;
  configFile = pkgs.writeText "nwstats.cfg" ''
    SECRET_KEY="${cfg.secretKey}"
    TODOIST_API_KEY="${cfg.todoistApiKey}"
    NOBBOFIN_PATH="/var/lib/nobbofin/nobbofin"
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
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = config.ptsd.nobbofin-autofetch.enable;
        message = "nobbofin-autofetch is required for nwstats.";
      }
    ];

    ptsd.secrets.files."nwstats.cfg" = {
      path = "/run/nwstats/nwstats.cfg";
    };

    systemd.services.nwstats = {
      description = "nwstats HTTP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartIfChanged = true;

      environment =
        let
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
            --workers 3 \
            --log-level info
          '';
        Restart = "on-failure";
        StateDirectory = "nobbofin";
        NoNewPrivileges = true;
        LimitNPROC = 32;
        LimitNOFILE = 1024;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        DynamicUser = true;
        RuntimeDirectory = "nwstats";
      };
    };

  };
}
