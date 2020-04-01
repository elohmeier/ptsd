{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/bs53lan.nix>
      <ptsd/2configs/cli-tools.nix>
      <ptsd/2configs/nwhost.nix>
      <secrets-shared/nwsecrets.nix>

      <ptsd/2configs/postgresql.nix>
    ];

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "nw27";
  };

  # environment.variables = {
  #   KAPACITOR_URL = "https://nuc1.host.nerdworks.de:9092";
  # };

  networking.firewall.allowedTCPPorts = [
    5432 # postgresql
  ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    hostName = "nuc1";
    interfaces.eth0.useDHCP = true;
  };

  boot.kernelParams = [ "ip=192.168.178.10::192.168.178.1:255.255.255.0:${config.networking.hostName}:eth0:off" ];

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostECDSAKey = toString <secrets> + "/initrd-ssh-key";
    };
    postCommands = ''
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
  };

  ptsd.nwbackup.paths = [ "/mnt/int" ];
}
