{ config, lib, pkgs, ... }:
with lib;
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/hardened.nix
    ../../2configs/nwhost.nix
    ../../2configs/prometheus/node.nix
    ../../2configs/users/enno.nix # for git repo support

    ./modules/backup.nix
    ./modules/fraam-gdrive-backup.nix
    #./modules/grafana.nix
    ./modules/home-assistant.nix
    ./modules/icloudpd.nix
    #./modules/loki.nix
    #./modules/octoprint.nix
    ./modules/postgresql.nix
    ./modules/prometheus
    ./modules/samba.nix
    ./modules/syncthing.nix
  ];

  environment.systemPackages = with pkgs;[ rmlint vim ];

  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  # ptsd.fluent-bit = {
  #   enable = true;
  # };

  ptsd.tailscale = {
    enable = true;
    cert.enable = true;
    ip = "100.101.207.64";
    httpServices = [
      "alertmanager"
      #"grafana"
      "home-assistant"
      #"mjpg-streamer"
      "monica"
      #"navidrome"
      #"octoprint"
      "prometheus-server"
    ];
  };

  ptsd.nwbackup.enable = false;

  # broken due to missing instruction set required by tensorflow1-bin
  # ptsd.photoprism = {
  #   enable = true;
  #   httpHost = "191.18.19.37";
  #   httpPort = 2342;
  #   siteUrl = "https://fotos.nerdworks.de/";
  #   photosDirectory = "/tank/enc/rawphotos/photos";
  # };

  ptsd.monica = {
    enable = true;
    domain = config.ptsd.tailscale.fqdn;
    appUrl = "https://${config.ptsd.tailscale.fqdn}:${toString config.ptsd.ports.monica}";
    extraEnv = {
      APP_KEY = "dummydummydummydummydummydummydu";
    };
  };

  networking = {
    hostName = "nas1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
    firewall.trustedInterfaces = [ "eno1" ];
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:eno1:off" ];

  # route traffic from/to nwvpn
  ptsd.wireguard = {
    enableGlobalForwarding = true;
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "tank";
  };

  # ptsd.navidrome = {
  #   enable = true;
  #   musicFolder = "/tank/enc/media";
  # };

  systemd.services.prometheus-check_ssl_cert = {
    description = "monitor ssl/tlsa/dane for nerdworks.de mail";
    environment = {
      # use google dns for TLSA lookup
      HOME = pkgs.writeTextFile {
        name = "digrc";
        text = "@8.8.8.8";
        destination = "/.digrc";
      };
    };
    path = with pkgs; [
      # checkSSLCert deps
      dig
      gawk
      glibc
      nettools

      bash
      checkSSLCert
      moreutils # sponge
    ];
    script = ''
      ${../../4scripts/prometheus-check_ssl_cert.sh} | sponge /var/log/prometheus-check_ssl_cert.prom
    '';
    startAt = "*:0/15"; # every 15 mins
  };
}
