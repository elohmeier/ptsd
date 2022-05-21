{ config, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/prometheus/node.nix
  ];

  ptsd.motion = {
    enable = true;
    hostName = "rpi1.fritz.box";
  };

  ptsd.nwacme.enable = false;
  ptsd.nwbackup.enable = false;
  ptsd.neovim.enable = false;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi1";
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    wireless.enable = true; # iwd seems to be incompatible with the onboard wifi or the rpi kernel config
    firewall.interfaces.wlan0.allowedTCPPorts = [ 80 ];
  };

  ptsd.secrets.files."wpa_supplicant.conf" = {
    dependants = [ "wpa_supplicant.service" ];
    path = "/etc/wpa_supplicant.conf";
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

  # services.getty.autologinUser = "root";
}
