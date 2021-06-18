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
    ../../2configs/desktop.nix
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix
    ../../2configs/themes/fraam.nix

    ../../2configs/prometheus/node.nix

    ../../2configs/octoprint-klipper-ender3.nix
    ../../2configs/hl5380dn.nix
  ];

  # ptsd.fraamdb = {
  #   enable = true;
  #   devSrc = "/home/enno/repos/fraamdb";
  #   debug = true;
  #   domain = "127.0.0.1";
  #   httpsOnly = false;
  # };

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

    #  hosts = {
    #    "10.129.120.124" = [ "forum.bart.htb" "bart.htb" "monitor.bart.htb" "internal-01.bart.htb" ];
    #  };
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
      "games"
      "kvm"
      "media"
      "office"
      "sec"
    ];
  };

  ptsd.nwacme.hostCert.enable = false;

  ptsd.nwbackup = {
    enable = true;
    paths = [ "/home" ];
  };

  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
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

  users.users.scanner = { isSystemUser = true; };

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
        devices = [ "nas1" "nuc1" "tp1" "tp1-win10" "ws1" "ws1-win10" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "tp1" "ws1" ];
      };
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "HL5380DN";
  };

  services.printing = {
    enable = true;
  };
}
