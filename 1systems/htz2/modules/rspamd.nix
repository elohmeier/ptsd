{ config, lib, pkgs, ... }:

{

  services.rspamd = {
    enable = true;

    locals = {
      "classifier-bayes.conf".text = ''
        servers = "127.0.0.1";
        backend = "redis";
      '';
      "options.inc".text = ''
        dns {
          nameserver = "master-slave:127.0.0.1:53:10,8.8.8.8:53:1";
        }
      '';
      "worker-controller.inc".source = config.ptsd.secrets.files."rspamd-worker-controller.inc".path;
    };

    workers = {
      normal = {
        includes = [ "$CONFDIR/worker-normal.inc" ];
        bindSockets = [{
          socket = "/run/rspamd/rspamd.sock";
          mode = "0660";
          owner = "${config.services.rspamd.user}";
          group = "${config.services.rspamd.group}";
        }
          "127.0.0.1:11333"
          "[::1]:11333"];
      };
      controller = {
        includes = [ "$CONFDIR/worker-controller.inc" ];
        bindSockets = [ "[::1]:11334" ];
      };
    };
  };

  services.redis = {
    enable = true;
    vmOverCommit = true;
    settings = {
      maxmemory = "500mb";
      maxmemory-policy = "volatile-ttl";
    };
  };

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
      };
    };
  };

  systemd.services.rspamd.serviceConfig.LogNamespace = "mail";
  systemd.services.redis.serviceConfig.LogNamespace = "mail";
  systemd.services.unbound.serviceConfig.LogNamespace = "mail";

  ptsd.secrets.files."rspamd-worker-controller.inc" = {
    dependants = [ "rspamd.service" ];
    owner = config.services.rspamd.user;
    group-name = config.services.rspamd.group;
  };

  users.groups.keys.members = [ config.services.rspamd.user ];
}
