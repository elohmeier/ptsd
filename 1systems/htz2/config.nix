{ config, lib, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
  nets = universe.hosts."${config.networking.hostName}".nets;
in
{
  imports =
    [
      ../..
      ../../2configs
      ../../2configs/borgbackup.nix
      ../../2configs/hardened.nix
      ../../2configs/nwhost-mini.nix
      ../../2configs/prometheus-node.nix

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

  security.acme.certs."htz2.nn42.de".postRun = "systemctl restart maddy.service";

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

  system.stateVersion = "21.11";
}
