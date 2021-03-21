{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ../../.
    ../../2configs
    ../../2configs/cli-tools.nix
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix
    ../../2configs/themes/fraam.nix

    ../../2configs/prometheus/node.nix

    <secrets-shared/nwsecrets.nix>

    <home-manager/nixos>
  ];

  home-manager = {
    users.mainUser = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  networking = {
    hostName = "ws2";
    useNetworkd = true;
    useDHCP = false;

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };

    wireless.iwd.enable = true;

    firewall.interfaces.wlan0 = {
      # samba/cups ports
      allowedTCPPorts = [ 631 445 139 ];
      allowedUDPPorts = [ 631 137 138 ];
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ptsd.cli = {
    enable = true;
    fish.enable = true;
    defaultShell = "fish";
  };

  ptsd.desktop = {
    enable = true;
    profiles = [
      "3dprinting"
      "admin"
      "dev"
      #"games"
      "kvm"
      "media"
      "office"
    ];
  };

  ptsd.nwacme.hostCert.enable = false;

  services.samba = {
    enable = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      hosts allow = 192.168.1.0/24
      hosts deny = 0.0.0.0/0
      map to guest = Bad User
    '';
    shares = {
      home = {
        path = "/home/enno";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
      scans = {
        path = "/home/enno/repos/nobbofin/000_INBOX/scans";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "force group" = "users";
        "force user" = "enno";
      };
    };
  };

  users.users.scanner = { };
}
