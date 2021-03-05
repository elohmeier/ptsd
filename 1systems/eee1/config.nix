with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    #<ptsd/2configs/prometheus/node.nix>

    <secrets/wifi.nix>
    <secrets-shared/nwsecrets.nix>

    <home-manager/nixos>
  ];

  # home-manager = {
  #   users.mainUser = { ... }:
  #     {
  #       imports = [
  #         ./home.nix
  #       ];
  #     };
  #   users.root = { ... }:
  #     {
  #       imports = [
  #         ./home.nix
  #       ];
  #     };
  # };

  networking = {
    hostName = "eee1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp4s0.useDHCP = true;
    interfaces.wlp1s0.useDHCP = true;
    wireless.enable = true;
  };

  systemd.network.networks = {
    "40-enp4s0" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
  };

  services.logind.lidSwitch = "ignore";

  # ptsd.desktop = {
  #   enable = true;
  #   audio.enable = false;
  #   bluetooth.enable = false;
  #   qt.enable = false;
  #   profiles = [
  #   ];
  # };

}
