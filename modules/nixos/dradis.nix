{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.dradis;

  yaml = pkgs.formats.yaml { };

  databaseYml = yaml.generate "database.yml" {
    production = {
      adapter = "sqlite3";
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
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "pt.nn42.de";
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
        REDIS_URL = "redis://localhost:6379/0";
      };

      preStart = ''
        mkdir -p /var/lib/dradis/{attachments,tmp}
        mkdir -p /run/dradis/{config,templates,public}

        cp -r ${cfg.package}/share/dradis/config.dist/* /run/dradis/config/
        cp -r ${cfg.package}/share/dradis/templates.dist/* /run/dradis/templates/
        cp -r ${cfg.package}/share/dradis/public.dist/* /run/dradis/public/

        cp -f ${databaseYml} /run/dradis/config/database.yml

        chmod -R 700 /run/dradis/{config,templates}

        # remove last line
        sed -i '$ d' /run/dradis/config/environments/production.rb
        echo "config.action_cable.allowed_request_origins = [ 'https://${cfg.hostname}' ]" >> /run/dradis/config/environments/production.rb
        echo "end" >> /run/dradis/config/environments/production.rb

        ${cfg.package.rubyEnv}/bin/rails db:prepare

        if ! [ -e /var/lib/dradis/secret_key_base ]; then
          ${cfg.package.rubyEnv}/bin/rake secret > /var/lib/dradis/secret_key_base
        fi
      '';

      script = ''
        export SECRET_KEY_BASE=$(cat /var/lib/dradis/secret_key_base)
        ${cfg.package.rubyEnv}/bin/bundle exec ${cfg.package.rubyEnv}/bin/rails server -b 127.0.0.1 -p 8080
      '';

      path = [
        pkgs.nodejs_16
      ];

      serviceConfig = {
        DynamicUser = true;
        User = "dradis";
        StateDirectory = "dradis";
        LogsDirectory = "dradis";
        RuntimeDirectory = "dradis";
        WorkingDirectory = "${cfg.package}/share/dradis";

        # hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = "";
        DevicePolicy = "closed";
        LockPersonality = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [ "AF_INET" ];
        RestrictNamespaces = true;
        RestrictNetworkInterfaces = [ "lo" ];
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        UMask = "0077";
      };
    };

    # systemd.services.dradis-worker = {
    #   description = "Dradis Framework Background Worker";
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "network.target" "dradis.service" ];
    #   wants = [ "network.target" "dradis.service" ];
    #
    #   environment = {
    #     RAILS_ENV = "production";
    #     REDIS_URL = "redis://localhost:6379/0";
    #   };
    #   serviceConfig = {
    #     DynamicUser = true;
    #     User = "dradis";
    #     ExecStart = "${cfg.package.rubyEnv}/bin/bundle exec ${cfg.package.rubyEnv}/bin/rake resque:work";
    #     StateDirectory = "dradis";
    #     LogsDirectory = "dradis";
    #     # RuntimeDirectory = "dradis";
    #     WorkingDirectory = "${cfg.package}/share/dradis";
    #   };
    # };

    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      # upstreams.dradis.servers."unix:/run/dradis/sockets/unicorn.sock" = { };
      upstreams.dradis.servers."127.0.0.1:8080" = { };

      virtualHosts.${cfg.hostname} = {
        enableACME = true;
        forceSSL = true;
        root = "${cfg.package}/share/dradis/public";

        locations = {
          "/".tryFiles = "$uri @dradis";
          "@dradis" = {
            proxyPass = "http://dradis";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host $host;
              proxy_redirect off;
            '';
          };
          "/assets".root = "${cfg.package}/share/dradis/public.dist";
          "/cable" = {
            proxyPass = "http://dradis/cable";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Connection "Upgrade";
              proxy_set_header Host $host;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };

    services.redis = {
      vmOverCommit = true;

      servers.dradis = {
        enable = true;
        port = 6379;
        settings = {
          maxmemory = "500mb";
          maxmemory-policy = "volatile-ttl";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults.email = lib.mkDefault "elo-lenc@nerdworks.de";
    };
  };
}
