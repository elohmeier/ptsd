{ config, pkgs, modulesPath, ... }:
{
  imports = [
    #../..
    #../../2configs
    #../../2configs/nwhost-mini.nix
    ../../2configs/users/enno.nix

    #../../2configs/prometheus/node.nix

    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi4";
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    firewall.allowedTCPPorts = [ 8000 8080 ];

    # wpa_supplicant
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
  };

  # allow hot-plug
  systemd.network.networks."40-eth0".networkConfig.ConfigureWithoutCarrier = true;
}
