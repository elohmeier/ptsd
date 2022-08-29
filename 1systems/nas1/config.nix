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
    ../../2configs/prometheus-node.nix
    ../../2configs/users/enno.nix # for git repo support

    #./modules/loki.nix
    #./modules/octoprint.nix
    ./modules/fraam-gdrive-backup.nix
    ./modules/icloudpd.nix
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

  ptsd.tailscale = {
    enable = true;
    cert.enable = true;
    ip = "100.101.207.64";
    httpServices = [
      #"mjpg-streamer"
      #"navidrome"
      #"octoprint"
    ];
  };

  # broken due to missing instruction set required by tensorflow1-bin
  # ptsd.photoprism = {
  #   enable = true;
  #   httpHost = "191.18.19.37";
  #   httpPort = 2342;
  #   siteUrl = "https://fotos.nerdworks.de/";
  #   photosDirectory = "/tank/enc/rawphotos/photos";
  # };

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
}
