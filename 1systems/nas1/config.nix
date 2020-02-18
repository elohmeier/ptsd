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
    <ptsd/2configs/postgresql.nix>

    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    hostName = "nas1";
    useNetworkd = true;
    useDHCP = false;
    interfaces."eth0".useDHCP = true;

    # NAT for Syncthing-Containers (NextCloud-Support)
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eth0";
    };
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=192.168.178.12::192.168.178.1:255.255.255.0:${config.networking.hostName}:eth0:off" ];

  ptsd.nwtraefik = {
    enable = true;
  };
}
