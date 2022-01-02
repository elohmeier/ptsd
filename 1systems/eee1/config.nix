{ config, lib, pkgs, ... }:

{
  imports = [
    ../../.
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/profiles/minimal.nix
    ../../2configs/prometheus/node.nix

    ./modules/fluidd.nix
    ./modules/klipper.nix
    ./modules/moonraker.nix
  ];

  networking = {
    hostName = "eee1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp4s0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    wireless.iwd.enable = true;
  };

  # wifi credentials
  ptsd.secrets.files."Bundesdatenschutzzentrale.psk".path = "/var/lib/iwd/Bundesdatenschutzzentrale.psk";

  systemd.network.networks."40-enp4s0".linkConfig.ActivationPolicy = "manual";

  services.logind.lidSwitch = "ignore";

  ptsd.nwacme.enable = false;
  ptsd.nwbackup.enable = false;
}
