{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ../../.
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/prometheus/node.nix
    ../../2configs/octoprint-klipper-ender3.nix
    ../../2configs/hl5380dn.nix
  ];

  ptsd.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so -f 15 -r 640x480"; # physical resolution: 1280x1024 (1.3 MP)
    outputPlugin = "output_http.so -w @www@ -n -p ${toString config.ptsd.nwtraefik.ports.mjpg-streamer}";
  };

  ptsd.nwtraefik =
    let
      universe = import ../../2configs/universe.nix;
    in
    {
      enable = true;

      services = [
        {
          name = "octoprint";
          entryPoints = [ "nwvpn-http" ];
          rule = "Host(`eee1.nw`)";
          tls = false;
        }
        {
          name = "mjpg-streamer";
          entryPoints = [ "nwvpn-http" ];
          rule = "Host(`eee1.nw`) && PathPrefix(`/mjpg/`)";
          stripPrefixes = [ "/mjpg/" ];
          tls = false;
        }
      ];

      entryPoints = {
        nwvpn-http = {
          address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:80";
        };
      };
    };

  networking = {
    hostName = "eee1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp4s0.useDHCP = true;
    interfaces.wlp1s0.useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlp1s0" ];
    };
  };

  ptsd.secrets.files = {
    "wpa_supplicant.conf" = {
      dependants = [ "wpa_supplicant.service" ];
      path = "/etc/wpa_supplicant.conf";
    };
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
  #   terminalConfig = "termite";
  #   numlockAuto = false;
  # };

  # reduce size
  environment.noXlibs = true;
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  ptsd.cups-airprint = {
    enable = true;
    lanDomain = "lan";
    listenAddress = "192.168.1.133:631";
    printerName = "HL5380DN";
  };
}
