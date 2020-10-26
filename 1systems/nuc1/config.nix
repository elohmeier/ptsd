{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/stateless-root.nix>

      <ptsd/2configs/baseX.nix>
      <ptsd/2configs/themes/nerdworks.nix>
      #<ptsd/2configs/nextcloud-client.nix>
      #<ptsd/2configs/prometheus/node.nix>

      <secrets-shared/nwsecrets.nix>
      <client-secrets/dbk/vdi.nix>
      <ptsd/2configs/home-secrets.nix>

      <home-manager/nixos>
    ];

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  # ptsd.nwbackup-server = {
  #   enable = true;
  #   zpool = "nw27";
  # };

  # environment.variables = {
  #   KAPACITOR_URL = "https://nuc1.host.nerdworks.de:9092";
  # };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    hostName = "nuc1";
    interfaces.eno1.useDHCP = true;
  };

  systemd.network.networks."40-eno1".networkConfig = {
    ConfigureWithoutCarrier = true;
  };

  # boot.kernelParams = [ "ip=192.168.178.10::192.168.178.1:255.255.255.0:${config.networking.hostName}:eno1:off" ];

  # boot.initrd.network = {
  #   enable = true;
  #   ssh = {
  #     enable = true;
  #     port = 2222;
  #     hostECDSAKey = toString <secrets> + "/initrd-ssh-key";
  #   };
  #   postCommands = ''
  #     echo "zfs load-key -a; killall zfs" >> /root/.profile
  #   '';
  # };

  # ptsd.nwbackup.paths = [ "/mnt/int" ];

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    wifi = {
      backend = "iwd";
      macAddress = "random";
      powersave = true;
    };
  };
  networking.wireless.iwd.enable = true;

  environment.systemPackages = with pkgs; [
    efibootmgr
    efitools
    tpm2-tools
  ];

  systemd.user.services.nm-applet = {
    description = "Network Manager applet";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [ pkgs.dbus ];
    serviceConfig = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      RestartSec = 3;
      Restart = "always";
    };
  };

}
