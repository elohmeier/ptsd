with import <ptsd/lib>;
{ config, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <secrets-shared/nwsecrets.nix>
    <ptsd/2configs/prometheus/node.nix>

    <ptsd/2configs/octoprint-klipper-ender3.nix>
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
