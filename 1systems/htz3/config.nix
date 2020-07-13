{ config, lib, pkgs, ... }:

let
  universe = import <ptsd/2configs/universe.nix>;
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
        addresses = [ { address = universe.hosts."${config.networking.hostName}".nets.www.ip6.addr; prefixLength = 64; } ];
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

  # when not null, for whatever reason this fails with:
  # cp: cannot stat '/var/src/secrets/initrd-ssh-key': No such file or directory
  # builder for '/nix/store/dwlv0grq7lmjayl1kk1jhsvgfz5flbwk-extra-utils.drv' failed with exit code 1
  boot.initrd.network.ssh.hostECDSAKey = lib.mkForce null;

  ptsd.nwbackup = {
    enable = true;
  };

  ptsd.nwtraefik = {
    enable = true;
    acmeEnabled = false;
    contentSecurityPolicy = "frame-ancestors 'self' https://*.fraam.de";
    certificates = [
      {
        certFile = "/var/lib/acme/htz3.host.fraam.de/cert.pem";
        keyFile = "/var/lib/acme/htz3.host.fraam.de/key.pem";
      }
      {
        certFile = "/var/lib/acme/dev.fraam.de/cert.pem";
        keyFile = "/var/lib/acme/dev.fraam.de/key.pem";
      }
      {
        certFile = "/var/lib/acme/fraam.de/cert.pem";
        keyFile = "/var/lib/acme/fraam.de/key.pem";
      }
    ];
    entryAddresses = {
      www4 = universe.hosts."${config.networking.hostName}".nets.www.ip4.addr;
      www6 = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]";
      loopback4 = "127.0.0.1";
    };
  };

  ptsd.fraam-www = {
    enable = true;
    extIf = "ens3";
  };

  users.groups.lego = {};

  security.acme = let
    envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
      ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
      ACME_DNS_API_BASE=https://auth.nerdworks.de
    '';
    email = "enno.lohmeier+letsencrypt@fraam.de";
  in
    {
      email = email;
      acceptTerms = true;
      certs = {
        "${config.networking.hostName}.${config.networking.domain}" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "${config.networking.hostName}.${config.networking.domain}";
          group = "lego";
          allowKeysForGroup = true;
          postRun = "systemctl restart traefik.service";
        };

        "fraam.de" = {
          extraDomains = { "www.fraam.de" = null; };
          dnsProvider = "acme-dns";
          credentialsFile = envFile "fraam.de";
          group = "lego";
          allowKeysForGroup = true;
          postRun = "systemctl restart traefik.service";
        };

        "dev.fraam.de" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "dev.fraam.de";
          group = "lego";
          allowKeysForGroup = true;
          postRun = "systemctl restart traefik.service";
        };
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
}
