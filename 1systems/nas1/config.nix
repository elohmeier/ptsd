with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/cups-airprint.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/nextcloud.nix>
    <ptsd/2configs/nobbofin-autofetch.nix>
    <ptsd/2configs/postgresql.nix>

    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    hostName = "nas1";
    useNetworkd = true;
    useDHCP = false;

    # Bridge is used for Nextcloud-Syncthing-Containers
    bridges.br0.interfaces = [ "eth0" ];
    interfaces.br0.useDHCP = true;

    hosts = {
      "192.168.178.10" = [ "nuc1.host.nerdworks.de" "nuc1" ]; # speed-up borg backup
    };
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=192.168.178.12::192.168.178.1:255.255.255.0:${config.networking.hostName}:eth0:off" ];

  ptsd.nwtraefik = {
    enable = true;
  };
}
