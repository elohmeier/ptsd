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
        default = "4G";
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
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = {
        "/var/src/secrets/gitlab" = {
          hostPath = "/var/src/secrets/gitlab";
          isReadOnly = true;
        };
        "/var/gitlab" = {
          hostPath = "${cfg.dataPath}/gitlab";
          isReadOnly = false;
        };
        "/var/gitlab/state/log" = {
          hostPath = "/var/log/gitlab";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "${cfg.dataPath}/postgresql";
          isReadOnly = false;
        };
      };
      ephemeral = true;
      timeoutStartSec = "5min"; # gitlab takes a while to start up

      config =
        { config, pkgs, ... }:
        {
          imports = [
            ../.
            ../2configs
          ];

          boot.isContainer = true;

          networking = {
            useHostResolvConf = false;
            nameservers = [ "8.8.8.8" "8.8.4.4" ];
            useNetworkd = true;
            firewall.allowedTCPPorts = [
              80 # for nginx
              config.ptsd.nwtraefik.ports.prometheus-node
              config.ptsd.nwtraefik.ports.prometheus-gitlab
            ];
          };

          time.timeZone = "Europe/Berlin";

          i18n = {
            defaultLocale = "de_DE.UTF-8";
            supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
          };

          ptsd.secrets.files = {
            "gitlab-initialRootPassword" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/initialRootPassword";
            };
            "gitlab-secret" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/secret";
            };
            "gitlab-db" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/db";
            };
            "gitlab-otp" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/otp";
            };
            "gitlab-jws" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/jws";
            };
            "gitlab-google-app-id" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/google-app-id";
            };
            "gitlab-google-app-secret" = {
              owner = config.services.gitlab.user;
              source-path = "/var/src/secrets/gitlab/google-app-secret";
            };
          };
          users.groups.keys.members = [ config.services.gitlab.user ];

          services.openssh.hostKeys = [
            {
              path = "/var/src/secrets/gitlab/ssh.id_ed25519";
              type = "ed25519";
            }
          ];

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
              user = "git"; # will be the user in the generated ssh urls
              databaseUsername = "git"; # must match the above username
              initialRootPasswordFile = config.ptsd.secrets.files."gitlab-initialRootPassword".path;
              secrets = {
                secretFile = config.ptsd.secrets.files."gitlab-secret".path;
                dbFile = config.ptsd.secrets.files."gitlab-db".path;
                otpFile = config.ptsd.secrets.files."gitlab-otp".path;
                jwsFile = config.ptsd.secrets.files."gitlab-jws".path;
              };
              smtp = {
                enable = true;
                address = "smtp-relay.gmail.com";
                port = 587;
                domain = "fraam.de";
              };
              extraConfig = {
                gitlab = {
                  email_display_name = "fraam GitLab";
                  email_reply_to = "noreply@fraam.de";
                  default_projects_features = {
                    issues = false;
                    merge_requests = true;
                    wiki = false;
                    snippets = false;
                    builds = true;
                    container_registry = false;
                  };
                  monitoring = {
                    ip_whitelist = [ "${cfg.hostAddress}/32" ];
                    sidekiq_exporter = {
                      address = cfg.containerAddress;
                      port = config.ptsd.nwtraefik.ports.prometheus-gitlab;
                    };
                  };
                };
                omniauth = {
                  enabled = true;
                  auto_sign_in_with_provider = "google_oauth2";
                  allow_single_sign_on = [ "google_oauth2" ];
                  block_auto_created_users = false;
                  providers = [{
                    name = "google_oauth2";
                    app_id = { _secret = config.ptsd.secrets.files."gitlab-google-app-id".path; };
                    app_secret = { _secret = config.ptsd.secrets.files."gitlab-google-app-secret".path; };
                    args = {
                      access_type = "offline";
                      approval_prompt = "";
                    };
                  }];
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
              locations."/" = {
                proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
                extraConfig = ''
                  proxy_set_header X-Forwarded-Proto https;
                '';
              };
            };
          };

          ptsd.nwlogrotate.config = ''
            /var/gitlab/state/log/*.log {
                su ${config.services.gitlab.user} ${config.services.gitlab.group}
                daily
                rotate 7
                missingok
                notifempty
                compress
                dateext
                dateformat .%Y-%m-%d
                copytruncate
            }
          '';

          services.prometheus.exporters.node = {
            enable = true;
            listenAddress = cfg.containerAddress;
            port = config.ptsd.nwtraefik.ports.prometheus-node;
            enabledCollectors = import ../2configs/prometheus/node_collectors.nix;
          };
        };
    };

    systemd.services."container@gitlab".serviceConfig = {
      CPUWeight = 20;
      MemoryMax = cfg.memLimit;
    };

    ptsd.nwtraefik = {
      entryPoints = {
        "ssh" = {
          address = ":22";
        };
      };
      services = [
        {
          url = "http://${cfg.containerAddress}:80";
          name = "gitlab";
          entryPoints = cfg.entryPoints;
          rule = "Host(`${cfg.domain}`)";
        }
        {
          name = "prometheus-gitlab-node";
          entryPoints = [ "nwvpn-prometheus" ];
          rule = "PathPrefix(`/gitlab/node`) && Host(`${config.ptsd.wireguard.networks.nwvpn.ip}`)";
          url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.prometheus-node}";
          tls = false;
          extraMiddlewares = [ "prom-stripprefix" ];
        }
        {
          name = "prometheus-gitlab-gitlab";
          entryPoints = [ "nwvpn-prometheus" ];
          rule = "PathPrefix(`/gitlab/gitlab`) && Host(`${config.ptsd.wireguard.networks.nwvpn.ip}`)";
          url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.prometheus-gitlab}";
          tls = false;
          extraMiddlewares = [ "prom-stripprefix" ];
        }
      ];
      extraDynamicConfig = {
        tcp = {
          routers.ssh = {
            entryPoints = [ "ssh" ];
            rule = "HostSNI(`*`)";
            service = "gitlab-ssh";
          };
          services = {
            gitlab-ssh.loadBalancer.servers = [{
              address = "${cfg.containerAddress}:22";
            }];
          };
        };
      };
    };

    networking = {
      firewall.interfaces.nwvpn.allowedTCPPorts = [ 9102 ]; # gitlab metrics port
      firewall.allowedTCPPorts = [ 22 ];
    };

    system.activationScripts.initialize-fraam-gitlab = stringAfter [ "users" "groups" ] ''
      mkdir -p ${cfg.dataPath}/gitlab
      mkdir -p ${cfg.dataPath}/postgresql
      mkdir -p /var/log/gitlab
      chown -R ${toString config.ids.uids.gitlab}:${toString config.ids.gids.gitlab} /var/log/gitlab
    '';
  };
}
