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
      ../../2configs/nwhost.nix
      ../../2configs/prometheus/node.nix

      ./modules/nerdworks-www.nix
      ./modules/nwgit.nix
    ];

  ptsd.nwbackup = {
    enable = true;
    paths = [
      "/var/lib/drone-server"
      "/var/lib/gitea"
      "/var/lib/postgresql"
      "/var/lib/wdplaner"
      "/var/lib/wdplaner-bak-20190620"
      "/var/www"
    ];
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz1";
    # metric is not used by systemd-networkd in 19.09,
    # so the route is configured below.
    #defaultGateway6 = {
    #  address = "fe80::1";
    #  metric = 42;
    #};
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = "2a01:4f8:c010:1adc::1"; prefixLength = 64; }];
      };
    };


    # reduce noise coming from www if
    firewall.logRefusedConnections = false;
  };

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  ptsd.wireguard.networks.nwvpn = {
    server.enable = true;
    routes = [
      { routeConfig = { Destination = "192.168.178.0/24"; }; }
    ];
  };

  ptsd.nwtraefik = {
    enable = true;
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
    };
    services = [
      {
        name = "nas1-public-www";
        rule = "Host(`www.nerdworks.de`) && PathPrefix(`/fpv`)";
        url = "http://${universe.hosts.nas1.nets.nwvpn.ip4.addr}:12345";
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
      {
        name = "nginx-wellknown-matrix";
        rule = "PathPrefix(`/.well-known/matrix`)";
        priority = 9999; # high-priority for router
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
      {
        name = "fotos";
        rule = "Host(`fotos.nerdworks.de`)";
        url = "http://191.18.19.37:2342";
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
    ];
    certificates =
      let
        crt = domain: {
          certFile = "/var/lib/acme/${domain}/cert.pem";
          keyFile = "/var/lib/acme/${domain}/key.pem";
        };
      in
      [
        (crt "nerdworks.de")
        (crt "fotos.nerdworks.de")
        (crt "git.nerdworks.de")
        #(crt "luisarichter.de")
      ];
  };

  security.acme.certs =
    let
      envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
        ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
        ACME_DNS_API_BASE=https://auth.nerdworks.de
      '';
    in
    {
      "nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        extraDomainNames = [ "www.nerdworks.de" ];
        credentialsFile = envFile "nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "fotos.nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        credentialsFile = envFile "fotos.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "git.nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        credentialsFile = envFile "git.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      # "luisarichter.de" = {
      #   email = "office@luisarichter.de";
      #   extraDomainNames = [ "www.luisarichter.de" ];
      #   dnsProvider = "acme-dns";
      #   credentialsFile = envFile "luisarichter.de";
      #   group = "certs";
      #   postRun = "systemctl restart traefik.service";
      # };

      "mqtt.nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        keyType = "rsa2048"; # https://tasmota.github.io/docs/TLS/#limitations
        credentialsFile = envFile "mqtt.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart mosquitto.service";
      };
    };

  ptsd.nwacme = {
    enable = true;
    http.enable = true;
    hostCert.useHTTP = true;
  };

  ptsd.mosquitto = {
    enable = true;
    certDomain = "mqtt.nerdworks.de";
    listeners = [
      { interface = "ens3"; ssl = true; }
    ];
  };

  networking.firewall.interfaces.ens3.allowedTCPPorts = [ config.ptsd.mosquitto.portSSL ];

  services.nginx = {
    enable = true;
    virtualHosts.nginx-wellknown-matrix = {
      listen = [{
        addr = "127.0.0.1";
        port = config.ptsd.nwtraefik.ports.nginx-wellknown-matrix;
      }];
      locations."/.well-known/matrix/server".extraConfig =
        let
          server = { "m.server" = "matrix.nerdworks.de:443"; };
        in
        ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';

      locations."/.well-known/matrix/client".extraConfig =
        let
          client = {
            "m.homeserver".base_url = "https://matrix.nerdworks.de";
            "m.identity_server".base_url = "https://vector.im";
          };
        in
        ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON client}';
        '';
    };
  };

}
