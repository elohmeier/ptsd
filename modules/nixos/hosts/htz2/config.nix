{ modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/profiles/hardened.nix")
      ./modules/maddy.nix
      ./modules/rspamd.nix
      ./modules/syncthing.nix
    ];

  services.borgbackup.jobs.hetzner.paths = [ "/var/lib/maddy" ];
  services.borgbackup.jobs.rpi4.paths = [ "/var/lib/maddy" ];

  # reduce size
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  services.journald.extraConfig = "Storage=volatile";

  ptsd.maddy = {
    enable = true;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz2";
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = "2a01:4f8:c2c:b468::1"; prefixLength = 64; }];
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

  security.acme.certs."htz2.nn42.de" = {
    postRun = "systemctl restart maddy.service";
    extraLegoRenewFlags = [ "--reuse-key" ]; # prevent requiring frequent tlsa record updates
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "htz2.nn42.de" = { addSSL = true; enableACME = true; serverAliases = [ "mail.nerdworks.de" ]; };
    };
  };

  # TODO, waiting for firmware >=7.50
  # systemd.network.netdevs.htz2wg = {
  #   netdevConfig = {
  #     Name = "htz2wg";
  #     Kind = "wireguard";
  #     MTUBytes = 1420;
  #   };
  #
  #   wireguardConfig = {
  #     PrivateKeyFile = "/run/credentials/systemd-networkd.service/htz2wg.key";
  #     ListenPort = 55555;
  #   };
  #
  #   wireguardPeers = [
  #     {
  #       wireguardPeerConfig = {
  #         PublicKey = "";
  #         PresharedKeyFile = "/run/credentials/systemd-networkd.service/htz2wg-fbhome.psk";
  #         AllowedIPs = "191.18.99.2/32";
  #       };
  #     }
  #   ];
  # };
  #
  # systemd.services.systemd-networkd.serviceConfig.LoadCredential = [
  #   "htz2wg.key:/var/src/secrets/htz2wg.key"
  #   "htz2wg-fbhome.psk:/var/src/secrets/htz2wg-fbhome.psk"
  # ];

  system.stateVersion = "21.11";
}
