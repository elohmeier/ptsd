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
    interfaces.wlan0.useDHCP = true;
    wireless.iwd.enable = true;

    nat = {
      enable = true;
      externalInterface = "wlan0";
      internalInterfaces = [ "enp4s0" ];
    };

    firewall.trustedInterfaces = [ "enp4s0" ];
    firewall.interfaces.enp4s0.allowedUDPPorts = [ 67 68 ]; # dhcp
  };

  environment.systemPackages = [ pkgs.tcpdump ];

  # wifi credentials
  ptsd.secrets.files."Bundesdatenschutzzentrale.psk".path = "/var/lib/iwd/Bundesdatenschutzzentrale.psk";

  systemd.network.networks."40-enp4s0" = {
    matchConfig = {
      Name = "enp4s0";
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      Address = "192.168.123.1/24";
      ConfigureWithoutCarrier = true;
      DHCPServer = true;
    };
  };

  services.logind.lidSwitch = "ignore";

  ptsd.nwacme.enable = false;
  ptsd.nwbackup.enable = false;
}
