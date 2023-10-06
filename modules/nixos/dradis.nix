{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.dradis;

  yaml = pkgs.formats.yaml { };

  databaseYml = yaml.generate "database.yml" {
    production = {
      adapter = "sqlite3";
      # pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      timeout = 5000;
      database = "/var/lib/dradis/production.sqlite3";
    };
  };
in
{
  options.ptsd.dradis = {
    enable = lib.mkEnableOption "Dradis Framework";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.dradis-ce;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.dradis = {
      description = "Dradis Framework";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      environment = {
        RAILS_ENV = "production";
      };

      preStart = ''
        mkdir -p /var/lib/dradis/{attachments,tmp}
        mkdir -p /run/dradis/{config,public}

        cp -r ${cfg.package}/share/dradis/config.dist/* /run/dradis/config/
        cp -r ${cfg.package}/share/dradis/public.dist/* /run/dradis/public/

        cp ${databaseYml} /run/dradis/config/database.yml

        ${cfg.package.rubyEnv}/bin/rails db:prepare
        # ${cfg.package.rubyEnv}/bin/rails db:seed
      '';

      path = [
        pkgs.nodejs_16
      ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package.rubyEnv}/bin/bundle exec ${cfg.package.rubyEnv}/bin/rails server -b 127.0.0.1 -p 8080";
        StateDirectory = "dradis";
        LogsDirectory = "dradis";
        RuntimeDirectory = "dradis";
        WorkingDirectory = "${cfg.package}/share/dradis";
      };
    };

  };
}
