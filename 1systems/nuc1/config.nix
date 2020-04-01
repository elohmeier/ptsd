{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/bs53lan.nix>
      <ptsd/2configs/cli-tools.nix>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/vsftpd.nix>
      <secrets-shared/nwsecrets.nix>

      <ptsd/2configs/postgresql.nix>
    ];

  users.users.media = {
    name = "media";
    isSystemUser = true;
    home = "/mnt/int/media";
    createHome = false;
    useDefaultShell = true;
    uid = 1001;
    description = "Media User";
    extraGroups = [];
  };

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "nw27";
  };

  ptsd.nwtelegraf = {
    extraConfig = {
      inputs.http = [
        {
          name_override = "email";
          urls = [ "http://127.0.0.1:8000/mail" ];
          data_format = "json";
          tag_keys = [ "account" "folder" ];
        }
        {
          name_override = "todoist";
          urls = [ "http://127.0.0.1:8000/todoist" ];
          data_format = "json";
          tag_keys = [ "project" ];
        }
        {
          name_override = "nobbofin";
          urls = [ "http://127.0.0.1:8000/nobbofin" ];
          data_format = "json";
        }
      ];
      inputs.x509_cert = [
        {
          sources = [
            "https://${config.networking.hostName}.${config.networking.domain}:443"
          ];
        }
      ];
    };
  };

  services.nwstats = {
    enable = true;
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
