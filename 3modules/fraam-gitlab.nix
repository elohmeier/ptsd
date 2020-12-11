{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraam-gitlab;
in
{
  options = {
    ptsd.fraam-gitlab = {
      enable = mkEnableOption "fraam-gitlab";
      extIf = mkOption {
        type = types.str;
        description = "external network interface container traffic will be NATed over";
      };
      containerAddress = mkOption {
        type = types.str;
        default = "192.168.100.16";
        description = "IP address of the container in the private host/container-network";
      };
      hostAddress = mkOption {
        type = types.str;
        default = "192.168.100.10";
        description = "IP address of the host in the private host/container-network";
      };
      domain = mkOption {
        type = types.str;
      };
      entryPoints = mkOption {
        type = with types; listOf str;
        default = [ "loopback6-http" "loopback6-https" ];
      };
      dataPath = mkOption {
        default = "/var/lib/fraam-gitlab";
      };
      memLimit = mkOption {
        default = "1G";
      };
    };
  };

  config = mkIf cfg.enable {


    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = cfg.extIf;
      };
    };

    containers.gitlab = {
      autoStart = false;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = {
        "/var/gitlab" = {
          hostPath = "${cfg.dataPath}/gitlab";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "${cfg.dataPath}/postgresql";
          isReadOnly = false;
        };
      };
      ephemeral = true;

      config =
        { config, pkgs, ... }:
        {
          imports = [
            <ptsd>
            <ptsd/2configs>
          ];

          boot.isContainer = true;

          networking = {
            useHostResolvConf = false;
            nameservers = [ "8.8.8.8" "8.8.4.4" ];
            useNetworkd = true;
            firewall.allowedTCPPorts = [ 80 ]; # for nginx
          };

          time.timeZone = "Europe/Berlin";

          i18n = {
            defaultLocale = "de_DE.UTF-8";
            supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
          };

          # steps to o create an initial admin user:
          # 1. create user using webinterface
          # 2. open console using `sudo -u gitlab -H gitlab-rails console -e production`
          # 3. select user using `user = User.where(id: 1).first`
          # 4. use `user.activate!` and `user.admin = true`, then `user.save!`

          services.gitlab =
            {
              enable = true;
              host = cfg.domain;
              port = 443;
              https = true;
              initialRootPasswordFile = pkgs.writeText "gitlab-initialRootPasswordFile" "todo";
              secrets = {
                secretFile = pkgs.writeText "gitlab-secretFile" "todo";
                dbFile = pkgs.writeText "gitlab-dbFile" "todo";
                otpFile = pkgs.writeText "gitlab-otpFile" "todo";
                jwsFile = pkgs.writeText "gitlab-jwsFile" "todo";
              };
              smtp = {
                enable = true;
                address = "smtp-relay.gmail.com";
                port = 587;
                domain = cfg.domain;
              };
              extraConfig = {
                gitlab = {
                  default_projects_features = {
                    issues = false;
                    merge_requests = true;
                    wiki = false;
                    snippets = false;
                    builds = true;
                    container_registry = false;
                  };
                };
              };
            };

          # waits for https://github.com/traefik/traefik/issues/4881
          services.nginx = {
            enable = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedProxySettings = true;
            virtualHosts."${cfg.domain}" = {
              locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            };
          };
        };
    };

    systemd.services."container@gitlab".serviceConfig.MemoryMax = cfg.memLimit;

    ptsd.nwtraefik = {
      services = [
        {
          url = "http://${cfg.containerAddress}:80";
          name = "gitlab";
          entryPoints = cfg.entryPoints;
          rule = "Host(`${cfg.domain}`)";
        }
      ];
    };

    system.activationScripts.initialize-fraam-gitlab = stringAfter [ "users" "groups" ] ''
      mkdir -p ${cfg.dataPath}/gitlab
      mkdir -p ${cfg.dataPath}/postgresql
    '';
  };
}
