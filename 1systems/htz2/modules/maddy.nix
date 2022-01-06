{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.maddy;

  aliases = pkgs.writeText "aliases" ''
    info@nerdworks.de: enno@nerdworks.de
    enno.lohmeier@nerdworks.de: enno@nerdworks.de
    enno.richter@nerdworks.de: enno@nerdworks.de
    postmaster: enno@nerdworks.de
    e.lohmeier@gmx.de: enno@nerdworks.de
    lulu@nerdworks.de: enno@nerdworks.de
    paypal@nerdworks.de: enno@nerdworks.de
  '';

  filterCommand = pkgs.writers.writePython3 "maddy-filter" { } ./maddy-filter.py;

  configFile = pkgs.writeText "maddy.conf" ''
    ## Maddy Mail Server - default configuration file (2021-03-07)
    # Suitable for small-scale deployments. Uses its own format for local users DB,
    # should be managed via maddyctl utility.
    #
    # See tutorials at https://maddy.email for guidance on typical
    # configuration changes.
    #
    # See manual pages (also available at https://maddy.email) for reference
    # documentation.

    # ----------------------------------------------------------------------------
    # Base variables

    $(hostname) = htz2.host.nerdworks.de
    $(primary_domain) = nerdworks.de
    $(local_domains) = $(primary_domain) ennolohmeier.de nerd-works.de

    tls file /var/lib/acme/$(hostname)/fullchain.pem /var/lib/acme/$(hostname)/key.pem

    # ----------------------------------------------------------------------------
    # Local storage & authentication

    # pass_table provides local hashed passwords storage for authentication of
    # users. It can be configured to use any "table" module, in default
    # configuration a table in SQLite DB is used.
    # Table can be replaced to use e.g. a file for passwords. Or pass_table module
    # can be replaced altogether to use some external source of credentials (e.g.
    # PAM, /etc/shadow file).
    #
    # If table module supports it (sql_table does) - credentials can be managed
    # using 'maddyctl creds' command.

    auth.pass_table local_authdb {
      table sql_table {
        driver sqlite3
        dsn credentials.db
        table_name passwords
      }
    }

    # imapsql module stores all indexes and metadata necessary for IMAP using a
    # relational database. It is used by IMAP endpoint for mailbox access and
    # also by SMTP & Submission endpoints for delivery of local messages.
    #
    # IMAP accounts, mailboxes and all message metadata can be inspected using
    # imap-* subcommands of maddyctl utility.

    storage.imapsql local_mailboxes {
      driver sqlite3
      dsn imapsql.db
      imap_filter {
        command ${filterCommand} --account_name {account_name} --sender {sender} { }
      }
    }

    # ----------------------------------------------------------------------------
    # SMTP endpoints + message routing

    hostname $(hostname)

    msgpipeline local_routing {
      # Insert handling for special-purpose local domains here.
      # e.g.
      # destination lists.example.org {
      #   deliver_to lmtp tcp://127.0.0.1:8024
      # }

      check {
        rspamd
      }

      destination $(local_domains) {
        modify {
          replace_rcpt regexp "elo-.+@nerd-?works.de" enno@$(primary_domain)
          replace_rcpt file ${aliases}
        }

        deliver_to &local_mailboxes
      }

      destination postmaster $(local_domains) {
        modify {
          replace_rcpt regexp "(.+)\+(.+)@(.+)" "$1@$3"
          replace_rcpt file ${aliases}
        }

        deliver_to &local_mailboxes
      }

      default_destination {
        reject 550 5.1.1 "User doesn't exist"
      }
    }

    smtp tcp://0.0.0.0:25 {
        limits {
          # Up to 20 msgs/sec across max. 10 SMTP connections.
          all rate 20 1s
          all concurrency 10
        }

        dmarc yes
        check {
          require_mx_record
          dkim
          spf
        }

        source $(local_domains) {
          reject 501 5.1.8 "Use Submission for outgoing SMTP"
        }
        default_source {
          destination postmaster $(local_domains) {
            deliver_to &local_routing
          }
          default_destination {
            reject 550 5.1.1 "User doesn't exist"
          }
        }
    }

    submission tls://0.0.0.0:465 tcp://0.0.0.0:587 {
      limits {
        # Up to 50 msgs/sec across any amount of SMTP connections.
        all rate 50 1s
      }

      auth &local_authdb

      source $(local_domains) {
        destination postmaster $(local_domains) {
          deliver_to &local_routing
        }
        default_destination {
          modify {
            dkim $(primary_domain) $(local_domains) default
          }
          deliver_to &remote_queue
        }
      }
      default_source {
        reject 501 5.1.8 "Non-local sender domain"
      }
    }

    target.remote outbound_delivery {
      limits {
        # Up to 20 msgs/sec across max. 10 SMTP connections
        # for each recipient domain.
        destination rate 20 1s
        destination concurrency 10
      }
      mx_auth {
        dane
        mtasts {
          cache fs
          fs_dir mtasts_cache/
        }
        local_policy {
          min_tls_level encrypted
          min_mx_level none
        }
      }
    }

    target.queue remote_queue {
      target &outbound_delivery

      autogenerated_msg_domain $(primary_domain)
      bounce {
        destination postmaster $(local_domains) {
          deliver_to &local_routing
        }
        default_destination {
          reject 550 5.0.0 "Refusing to send DSNs to non-local addresses"
        }
      }
    }

    # ----------------------------------------------------------------------------
    # IMAP endpoints

    imap tls://0.0.0.0:993 tcp://0.0.0.0:143 {
      auth &local_authdb
      storage &local_mailboxes
    }

    openmetrics tcp://127.0.0.1:${toString config.ptsd.nwtraefik.ports.prometheus-maddy} { }
  '';
in
{
  options = {
    ptsd.maddy = {
      enable = mkEnableOption "maddy";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.maddy = {
      description = "Maddy Mail Server";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # see https://github.com/foxcpp/maddy/blob/master/dist/systemd/maddy.service
      serviceConfig = {
        LogNamespace = "mail";

        Type = "notify";
        NotifyAccess = "main";
        WorkingDirectory = "/var/lib/maddy";
        RuntimeDirectory = "maddy";
        StateDirectory = "maddy";
        LogsDirectory = "maddy";
        ExecStart = "${pkgs.maddy}/bin/maddy -config ${configFile}";
        DynamicUser = true;
        SupplementaryGroups = "certs";

        # Strict sandboxing. You have no reason to trust code written by strangers from GitHub.
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectControlGroups = true;

        # Additional sandboxing. You need to disable all of these options
        # for privileged helper binaries (for system auth) to work correctly.
        NoNewPrivileges = true;
        PrivateDevices = true;
        RestrictSUIDSGID = true;
        ProtectKernelModules = true;
        MemoryDenyWriteExecute = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        LockPersonality = true;

        # Graceful shutdown with a reasonable timeout.
        TimeoutStopSec = "7s";
        KillMode = "mixed";
        KillSignal = "SIGTERM";

        # Required to bind on ports lower than 1024.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";

        # Force all files created by maddy to be only readable by it.
        UMask = "0027";

        # Bump FD limitations. Even idle mail server can have a lot of FDs open (think
        # of idle IMAP connections, especially ones abandoned on the other end and
        # slowly timing out).
        LimitNOFILE = 131072;

        # Limit processes count to something reasonable to
        # prevent resources exhausting due to big amounts of helper
        # processes launched.
        LimitNPROC = 512;

        # Restart server on any problem.
        Restart = "on-failure";
        # ... Unless it is a configuration problem.
        RestartPreventExitStatus = 2;

        ExecReload = [
          "${pkgs.utillinux}/bin/kill -USR1 $MAINPID"
          "${pkgs.utillinux}/bin/kill -USR2 $MAINPID"
        ];
      };
    };

    environment.variables.MADDY_CONFIG = toString configFile;
    environment.systemPackages = [ pkgs.maddy ];

    networking.firewall.allowedTCPPorts = [
      25
      465
      587
      993
      143
    ];

    ptsd.nwbackup.extraPaths = [ "/var/lib/private/maddy" ];

    ptsd.nwtraefik = {
      services = [
        {
          name = "prometheus-maddy";
          entryPoints = [ "nwvpn-prometheus-http" ];
          rule = "PathPrefix(`/${config.networking.hostName}/maddy`) && Host(`${config.ptsd.wireguard.networks.nwvpn.ip}`)";
          tls = false;
          extraMiddlewares = [ "prom-stripprefix" ];
        }
      ];
    };

    # configured as in https://github.com/foxcpp/maddy/tree/master/dist/fail2ban/filter.d
    services.fail2ban.jails = {
      maddy-auth = ''
        enabled  = true
        port     = 993,465,25
        filter   = maddy-auth
        bantime  = 96h
        backend  = systemd
      '';

      maddy-dictionary-attack = ''
        enabled  = true
        port     = 993,465,25
        filter   = maddy-dictionary-attack
        bantime  = 72h
        maxtries = 3
        findtime = 6h
        backend  = systemd
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/maddy-auth.conf".text = ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex    = authentication failed\t\{\"reason\":\".*\",\"src_ip\"\:\"<HOST>:\d+\"\,\"username\"\:\".*\"\}$
        journalmatch = _SYSTEMD_UNIT=maddy.service + _COMM=maddy
      '';

      # spelling mistake "dictonary" present in maddy source code
      "fail2ban/filter.d/maddy-dictionary-attack.conf".text = ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex    = smtp\: MAIL FROM error repeated a lot\, possible dictonary attack\t\{\"count\"\:\d+,\"msg_id\":\".+\",\"src_ip\"\:\"<HOST>:\d+\"\}$
                       smtp\: too many RCPT errors\, possible dictonary attack\t\{\"msg_id\":\".+\","src_ip":"<HOST>:\d+\"\}
        journalmatch = _SYSTEMD_UNIT=maddy.service + _COMM=maddy
      '';
    };
  };
}
