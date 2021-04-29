with lib;
{ config, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix

    ../../2configs/prometheus/node.nix

    ../../2configs/octoprint-klipper-ender3.nix
  ];

  # fix often full /boot directory
  boot.loader.grub.configurationLimit = 2;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi5";
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    # wpa_supplicant
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
  };

  # allow hot-plug
  systemd.network.networks."40-eth0".networkConfig.ConfigureWithoutCarrier = true;

  services.resolved = {
    enable = true;
    dnssec = "false";
  };
}
