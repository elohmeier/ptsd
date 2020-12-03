{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
  bwSecrets = import <secrets/bitwarden.nix>;
in
{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost-mini.nix>
      <secrets-shared/nwsecrets.nix>

      #<ptsd/2configs/cli-tools.nix>
    ];

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
  };

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  ptsd.nwbackup = {
    enable = true;
  };

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
        (crt "htz3.host.fraam.de")
        (crt "dev.fraam.de")
        (crt "fraam.de")
        (crt "git.fraam.de")
        (crt "vault.fraam.de")
      ];
    entryPoints = {
      "www4-http" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.www.ip4.addr}:80";
        http.redirections.entryPoint = {
          to = "www4-https";
          scheme = "https";
          permanent = true;
        };
      };
      "www4-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.www.ip4.addr}:443";
      };
      "www6-http" = {
        address = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]:80";
        http.redirections.entryPoint = {
          to = "www6-https";
          scheme = "https";
          permanent = true;
        };
      };
      "www6-https" = {
        address = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]:443";
      };

      # added for local tls monitoring & fraam-update-static-web script
      "loopback4-https".address = "127.0.0.1:443";
    };
  };

  ptsd.fraam-www = {
    enable = true;
    extIf = "ens3";
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
        "${config.networking.hostName}.${config.networking.domain}" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "${config.networking.hostName}.${config.networking.domain}";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "fraam.de" = {
          extraDomainNames = [ "www.fraam.de" ];
          dnsProvider = "acme-dns";
          credentialsFile = envFile "fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "dev.fraam.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "dev.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "id.fraam.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "id.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "git.fraam.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "git.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        "vault.fraam.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "vault.fraam.de";
          group = "certs";
          postRun = "systemctl restart traefik.service";
        };

        # remember to add new certs to the traefik cert list :-)
      };
    };

  # users.users = {
  #   sharath = {
  #     name = "sharath";
  #     isNormalUser = true;
  #     home = "/home/sharath";
  #     createHome = true;
  #     useDefaultShell = true;
  #     uid = 1001;
  #     description = "Sharath Kumar Soudamalla";
  #     extraGroups = [ "wheel" ];
  #     openssh.authorizedKeys.keys = [
  #       "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgT/DdIqnIHX1Fomu2AxL6U0GmCBSllqAdIGV6920IYR/CbRzkILxnLNEF109lWG4/xg/VamXHobcNLy3EecQBFZKYBbsFV4x6FRa/dd1dYUGFVu746NY+kiV1ienoAOjs7/eUuKr5poppQD7snfPY8+fC/lCOU2yooepxlAi+XzvBDtfY5B7Ws52K0I4K+Sgpoej7sy0UipQsia1VehvakZ5M7toUj7Vu8R/jMWRnC5yGD6nX1xTJniIy1xB/MGLFigQrHY1cLgBPDLQOvEIRykqZiCJHCcq0lQax8unBgWPgt4bEr4m7JX4lrgKoqk3HOqy5qs61IVrXnwmAdF0XQ== rsa-key-20200427"
  #     ];
  #   };
  # };

  # security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [ tmux htop mc ];

  ptsd.nwbitwarden = {
    enable = true;
    domain = "vault.fraam.de";
    entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" "loopback4-https" ];
    extraConfig = {
      adminToken = bwSecrets.adminToken;
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
}
