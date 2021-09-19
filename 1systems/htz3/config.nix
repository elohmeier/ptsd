{ config, lib, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
in
{
  imports =
    [
      ../..
      ../../2configs
      ../../2configs/hardened.nix
      ../../2configs/nwhost-mini.nix

      ../../2configs/prometheus/node.nix

      ./modules/fraamdb.nix
      ./modules/fraam-gitlab.nix
      ./modules/fraam-www.nix
      ./modules/gitlab-runner-hcloud.nix
    ];

  ptsd.nwbackup = {
    enable = true;
    paths = [
      "/var/lib/fraam-gitlab/gitlab"
      "/var/lib/fraam-gitlab/postgresql" #  TODO: backup using script
      "/var/lib/fraam-www/www"
      "/var/lib/fraam-www/mysql-backup"
      "/var/lib/fraam-www/static"
      "/var/lib/postgresql" # TODO: backup using script
      "/var/lib/bitwarden_rs"
      "/var/src"
      "/var/www/intweb"
    ];
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz3";
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = universe.hosts."${config.networking.hostName}".nets.www.ip6.addr; prefixLength = 64; }];
      };
    };

    # set to let wget use local connection
    extraHosts = ''
      127.0.0.1 dev.fraam.de
    '';

    # reduce noise coming from www if
    firewall.logRefusedConnections = false;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=1G
  '';

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];


  services.openssh.ports = [ 1022 ]; # use non-standard ssh port to be able to forward standard port to gitlab container

  ptsd.nwtraefik = {
    enable = true;
    #logLevel = "DEBUG";
    contentSecurityPolicy = "frame-ancestors 'self' https://*.fraam.de";
    certificates =
      let
        crt = domain: {
          certFile = "/var/lib/acme/${domain}/cert.pem";
          keyFile = "/var/lib/acme/${domain}/key.pem";
        };
      in
      [
        (crt "htz3.host.fraam.de") # via ptsd.nwacme hostCert
        (crt "db.fraam.de")
        (crt "dev.fraam.de")
        (crt "fraam.de")
        (crt "int.fraam.de")
        (crt "git.fraam.de")
        (crt "vault.fraam.de")
      ];
    entryPoints = {
      "www4-http" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.www.ip4.addr}:80";
      };
      "www4-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.www.ip4.addr}:443";
      };
      "www6-http" = {
        address = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]:80";
      };
      "www6-https" = {
        address = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]:443";
      };
      "nwvpn-http" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:80";
      };
      "nwvpn-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:443";
      };

      # added for local tls monitoring & fraam-update-static-web script
      "loopback4-https".address = "127.0.0.1:443";
      "loopback6-https".address = "[::1]:443";
    };

    services = [
      {
        name = "nginx-fraam-intweb";
        rule = "Host(`int.fraam.de`)";
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];

        auth.forwardAuth = {
          address = "http://localhost:4181";
          authResponseHeaders = [ "X-Forwarded-User" ];
        };
      }
      {
        name = "nginx-wellknown-matrix";
        rule = "PathPrefix(`/.well-known/matrix`)";
        priority = 9999; # high-priority for router
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
    ];
  };

  ptsd.fraam-www = {
    enable = true;
    extIf = "ens3";
  };

  ptsd.fraam-gitlab = {
    enable = true;
    extIf = "ens3";
    domain = "git.fraam.de";
    entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" "loopback4-https" "loopback6-https" ];
  };

  security.acme =
    let
      envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
        ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
        ACME_DNS_API_BASE=https://auth.nerdworks.de
      '';
      email = "enno.richter+letsencrypt@fraam.de";
    in
    {
      email = email;
      acceptTerms = true;
      certs = {
        "fraam.de" = {
          extraDomainNames = [ "www.fraam.de" ];
          webroot = config.ptsd.nwacme.http.webroot;
          credentialsFile = envFile "fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "db.fraam.de" = {
          webroot = config.ptsd.nwacme.http.webroot;
          credentialsFile = envFile "db.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "dev.fraam.de" = {
          webroot = config.ptsd.nwacme.http.webroot;
          credentialsFile = envFile "dev.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "int.fraam.de" = {
          webroot = config.ptsd.nwacme.http.webroot;
          credentialsFile = envFile "int.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "git.fraam.de" = {
          webroot = config.ptsd.nwacme.http.webroot;
          credentialsFile = envFile "git.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "vault.fraam.de" = {
          webroot = config.ptsd.nwacme.http.webroot;
          credentialsFile = envFile "vault.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        # remember to add new certs to the traefik cert list :-)
      };
    };

  ptsd.nwacme = {
    enable = true;
    http.enable = true;
    hostCert = {
      enable = true;
      useHTTP = true;
    };
  };

  users.users = {
    intweb = {
      group = "nginx";
      shell = "/bin/sh";
      isSystemUser = true;
      openssh.authorizedKeys.keys =
        let
          sshPubKeys = import ../../2configs/users/ssh-pubkeys.nix; in
        [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLSWKSbb4KpKq9XqzyzvthDiL2I3RPkqpX4UgtpTkpM"
          sshPubKeys.sshPub.enno_yubi41
          sshPubKeys.sshPub.enno_yubi49
        ];
    };
  };

  environment.systemPackages = with pkgs; [ tmux htop mc ];

  ptsd.nwbitwarden = {
    enable = true;
    domain = "vault.fraam.de";
    entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" "loopback4-https" ];
    extraConfig = {
      smtpHost = "smtp-relay.gmail.com";
      smtpPort = 587;
      smtpSSL = true;
      smtpFrom = "vault@fraam.de";
      # smtpFromName = "fraam Vault"; # not working
      signupsAllowed = false;
      signupsDomainsWhitelist = "fraam.de";
      signupsVerify = true;
      enableEmail2Fa = true;
    };
  };

  services.fail2ban.enable = true;

  ptsd.fraamdb = {
    enable = true;
    domain = "db.fraam.de";
    entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
  };

  programs.mosh.enable = true;

  services.nginx = {
    enable = true;
    virtualHosts = {
      "fraam-intweb" = {
        listen = [{
          addr = "127.0.0.1";
          port = config.ptsd.nwtraefik.ports.nginx-fraam-intweb;
        }];

        root = "/var/www/intweb";
      };

      nginx-wellknown-matrix = {
        listen = [{
          addr = "127.0.0.1";
          port = config.ptsd.nwtraefik.ports.nginx-wellknown-matrix;
        }];
        locations."/.well-known/matrix/server".extraConfig =
          let
            server = { "m.server" = "matrix.fraam.de:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';

        locations."/.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver".base_url = "https://matrix.fraam.de";
              "m.identity_server".base_url = "https://vector.im";
            };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON client}';
          '';
      };
    };
  };

  system.activationScripts.initialize-var-www = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /var/www/intweb
    chown -R intweb:nginx /var/www/intweb
    chgrp -R nginx /var/www
    chmod -R u+rwX,go+rX,go-w /var/www
  '';
}
