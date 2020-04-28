with import <ptsd/lib>;
{ config, pkgs, ... }:

let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/bs53lan.nix>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/cups-airprint.nix>
    <ptsd/2configs/influxdb-kapacitor.nix>
    <ptsd/2configs/grafana.nix>
    <ptsd/2configs/home-assistant.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/monica-nginx.nix>
    <ptsd/2configs/mosquitto.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/nwstats-telegraf.nix>
    <ptsd/2configs/nextcloud.nix>
    <ptsd/2configs/postgresql.nix>
    <ptsd/2configs/prometheus/server.nix>

    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    hostName = "nas1";
    useNetworkd = true;
    useDHCP = false;

    # Bridge is used for Nextcloud-Syncthing-Containers
    bridges.br0.interfaces = [ "eno1" ];
    interfaces.br0.useDHCP = true;
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=192.168.178.12::192.168.178.1:255.255.255.0:${config.networking.hostName}:eno1:off" ];

  ptsd.nwtraefik = {
    enable = true;
  };

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "tank";
  };

  ptsd.samba-sonos = {
    enable = true;
    mediaPath = "/tank/enc/media";
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginx.override {
      modules = with pkgs.nginxModules; [ fancyindex ];
    };
    commonHttpConfig = ''
      charset UTF-8;
    '';
    virtualHosts = {
      "www.nerdworks.de" = {
        listen = [
          {
            addr = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
            port = 12345;
          }
        ];
        locations."/" = {
          alias = "/tank/enc/public-www/";
          extraConfig = ''
            fancyindex on;
            fancyindex_exact_size off;
          '';
        };
      };
    };
  };
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ 12345 ];
}
