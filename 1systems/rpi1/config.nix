{ config, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/prometheus/node.nix
  ];

  ptsd.nwacme.enable = false;
  ptsd.nwbackup.enable = false;
  ptsd.neovim.enable = false;
  ptsd.tor-ssh.enable = false;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi1";
    interfaces.eth0.useDHCP = true;
    wireless.iwd.enable = true;
  };

  systemd.network.networks."40-eth0" = {
    matchConfig = {
      Name = "eth0";
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      ConfigureWithoutCarrier = true;
    };
  };

  environment.systemPackages = with pkgs;[ motion ];
}
