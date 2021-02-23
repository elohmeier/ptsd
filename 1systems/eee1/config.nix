with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <ptsd/2configs/prometheus/node.nix>

    <secrets/wifi.nix>
    <secrets-shared/nwsecrets.nix>

    <home-manager/nixos>
  ];

  home-manager = {
    users.mainUser = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
    users.root = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "eee1";
    interfaces.ens1 = {
      # todo: check if name
      useDHCP = true;
    };
  };

  networking.wireless.enable = true;

  services.logind.lidSwitch = "ignore";
  services.pipewire.media-session.enable = false;

  #ptsd.desktop = {
  #  enable = true;
  #};
}
