{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/hardened.nix")

    ./modules/git.nix
    ./modules/loki.nix
    ./modules/monica.nix # TODO: use nixpkgs package
    ./modules/mosquitto.nix
    ./modules/prometheus
  ];

  environment.memoryAllocator.provider = "libc"; # php-fpm incompatible with scudo

  services.journald.extraConfig = "Storage=volatile";

  services.borgbackup.jobs =
    let
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
    in
    {
      hetzner = { inherit paths exclude; };
      rpi4 = { inherit paths exclude; };
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

    # nixos-fw-accept chain will be removed by the NixOS stop-script, so no extraStopCommands are needed
    # whitelist networks based on AS ip ranges, see update script
    firewall.extraCommands = let allowlist = builtins.fromJSON (builtins.readFile ./ip-allowlist.json); in ''
      iptables -A nixos-fw -p tcp -s ${builtins.concatStringsSep "," allowlist.ipv4} --match multiport --dports 8123 -j nixos-fw-accept
      ip6tables -A nixos-fw -p tcp -s ${builtins.concatStringsSep "," allowlist.ipv6} --match multiport --dports 8123 -j nixos-fw-accept
    '';
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
      "prometheus-pushgateway"
      "prometheus-server"
    ];
    links = [
      "monica"
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
      "htz1.nn42.de" = {
        addSSL = true;
        enableACME = true;
        listen = [
          { addr = "159.69.186.234"; port = 8123; ssl = true; }
          { addr = "[2a01:4f8:c010:1adc::1]"; port = 8123; ssl = true; }
        ];
        locations."/".extraConfig = ''
          proxy_http_version 1.1;
          proxy_pass https://rpi4.pug-coho.ts.net:8123;
          proxy_set_header Connection $connection_upgrade;
          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };

  system.stateVersion = "21.11";
}
