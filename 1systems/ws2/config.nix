{ config, lib, pkgs, ... }:
with lib;
let
  virshNatIpPrefix = "192.168.197"; # "XXX.XXX.XXX" without last block
  virshNatIf = "virsh-nat";
in
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

    interfaces = {
      "${virshNatIf}".ipv4.addresses = [{ address = "${virshNatIpPrefix}.1"; prefixLength = 24; }];
    };

    firewall.interfaces = {
      "${virshNatIf}" = {
        allowedTCPPorts = [ 53 631 445 139 ];
        allowedUDPPorts = [ 53 67 68 546 547 137 138 ];
      };

      wlan0 = {
        # samba/cups ports
        allowedTCPPorts = [ 631 445 139 ];
        allowedUDPPorts = [ 631 137 138 ];
      };
    };

    nat = {
      enable = true;
      externalInterface = "wlan0";
      internalInterfaces = [ virshNatIf ];
    };
  };

  systemd.network = {
    netdevs = {
      "40-${virshNatIf}" = {
        netdevConfig = {
          Name = virshNatIf;
          Kind = "bridge";
        };
      };
    };
    networks = {
      "40-${virshNatIf}" = {
        matchConfig.Name = virshNatIf;
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCPServer = true;
        };
      };
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
      hosts allow = 192.168.1.0/24 ${virshNatIpPrefix}.0/24
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
      public = {
        path = "/home/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
      };
    };
  };

  users.users.scanner = { };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false; # will be socket-activated
    };
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
      qemuRunAsRoot = false;
    };
  };

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "nas1-st-enno" "nuc1" "tp1" "tp1-win10" "ws1" "ws1-win10" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1-st-enno" "tp1" "ws1" ];
      };
    };
  };
}
