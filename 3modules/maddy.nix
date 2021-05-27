{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.maddy;

  aliases = pkgs.writeText "aliases" ''

  '';

  configFile = pkgs.writeText "maddy.conf" ''
    $(hostname) = htz2.host.nerdworks.de
    $(primary_domain) = ennolohmeier.de
    $(local_domains) = $(primary_domain)

    tls file /var/lib/acme/$(hostname)/fullchain.pem /var/lib/acme/$(hostname)/key.pem

    auth.pass_table local_authdb {
      table sql_table {
        driver sqlite3
        dsn credentials.db
        table_name passwords
      }
    }

    storage.imapsql local_mailboxes {
      driver sqlite3
      dsn imapsql.db
    }

    hostname $(hostname)

    msgpipeline local_routing {
        # Insert handling for special-purpose local domains here.
        # e.g.
        # destination lists.example.org {
        #     deliver_to lmtp tcp://127.0.0.1:8024
        # }

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

  };
}
