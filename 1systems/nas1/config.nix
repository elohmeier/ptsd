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
  };

  systemd.network = {
    enable = true;
    networks = {
      "99-main" = {
        matchConfig = {
          MACAddress = "a8:a1:59:04:c6:f8";
        };
        networkConfig = {
          Bridge = "virbr0";
        };
      };
      "virbr0" = {
        DHCP = "yes";
        matchConfig = {
          Name = "virbr0";
        };
      };
    };
    netdevs = {
      "virbr0" = {
        netdevConfig = {
          Name = "virbr0";
          Kind = "bridge";
        };
      };
    };
  };
}
