with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>

    <secrets-shared/nwsecrets.nix>
  ];

  boot.tmpOnTmpfs = true;

  networking = {
    hostName = "nas1";
    useNetworkd = true;
    useDHCP = false;
    interfaces."eth0".useDHCP = true;
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=192.168.178.12::192.168.178.1:255.255.255.0:${config.networking.hostName}:eth0:off" ];
}
