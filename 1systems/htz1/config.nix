{ config, lib, pkgs, ... }:
{
  imports =
    [
      ../..
      ../../2configs
      ../../2configs/borgbackup.nix
      ../../2configs/hardened.nix
      ../../2configs/nwhost.nix
      ../../2configs/prometheus-node.nix

      ./modules/home-assistant.nix
      ./modules/git.nix
      ./modules/monica.nix
      ./modules/mosquitto.nix
      ./modules/prometheus
    ];

  services.borgbackup.jobs.rpi4 = {
    paths = [
      "/var/backup"
      "/var/lib/gitolite"
      "/var/lib/grafana/data"
      "/var/lib/hass"
      "/var/lib/monica/storage"
      "/var/www"
    ];
    exclude = [
      "/var/lib/gitolite/.gitolite"
      "/var/lib/monica/storage/framework"
      "/var/lib/monica/storage/logs"
    ];
  };

  ptsd.secrets.files."nwvpn-fb1.psk" = {
    owner = "systemd-network";
    mode = "0440";
    dependants = [ "systemd-networkd.service" ];
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

    firewall.allowedTCPPorts = [ 80 443 ];
  };

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  ptsd.wireguard.networks.nwvpn = {
    server.enable = true;
    routes = [{ routeConfig = { Destination = "192.168.178.0/24"; }; }];
    reresolveDns = true; # fb1 connection / dyndns
    reresolveDnsInterval = "06:00";
  };

  ptsd.tailscale = {
    enable = true;
    cert.enable = true;
    ip = "100.106.245.41";
    httpServices = [
      "alertmanager"
      "grafana"
      "prometheus-server"
    ];
    links = [
      "home-assistant"
      "monica"
      "prometheus-pushgateway"
    ];
  };

  security.acme.certs."mqtt.nerdworks.de" = {
    keyType = "rsa2048";
    postRun = "systemctl restart mosquitto.service";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "mqtt.nerdworks.de" = { addSSL = true; enableACME = true; };
      "www.nerdworks.de" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/nerdworks.de/prod-v2";
        locations."/dl/".alias = "/var/www/nerdworks.de/dl/";
      };
      "nerdworks.de" = { addSSL = true; enableACME = true; globalRedirect = "www.nerdworks.de"; };
    };
  };

  system.stateVersion = "21.11";
}
