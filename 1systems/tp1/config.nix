{ config, lib, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
  virshNatIpPrefix = "192.168.197"; # "XXX.XXX.XXX" without last block
  virshNatIf = "virsh-nat";
in
{
  imports = [
    ../..
    ../../2configs
    #../../2configs/awscli.nix
    ../../2configs/desktop.nix
    #../../2configs/gcalcli.nix
    ../../2configs/mainUser.nix
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix

    ../../2configs/themes/dark.nix
    ../../2configs/mfc7440n.nix
    ../../2configs/hl5380dn.nix
    ../../2configs/prometheus/node.nix

    # 
    # ../../2configs/home-secrets.nix
  ];

  ptsd.cli = {
    enable = true;
    fish.enable = true;
    defaultShell = "fish";
  };

  ptsd.nwbackup = {
    paths = [ "/home" ];
  };

  services.hardware.bolt.enable = true;

  # workaround random wifi drops
  # see https://bugzilla.kernel.org/show_bug.cgi?id=203709
  boot.kernelPatches = [
    {
      name = "beacon_timeout.patch";
      patch = pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/mikezackles/linux-beacon-pkgbuild/8b6f0781a063405df78d6e31eabb12e60c51c814/beacon_timeout.patch";
        sha256 = "sha256-xBOvDaCqoK8Xa89ml4F14l6uokWMWsvdPnNg5HYMMag=";
      };
    }
  ];
  boot.extraModprobeConfig = ''
    options iwlwifi beacon_timeout=256
  '';

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    trayOutput = "eDP-1";
    profiles = [
      "3dprinting"
      "admin"
      "dev"
      "fpv"
      "kvm"
      "media"
      "office"
      "sec"
    ];
  };

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home-common.nix
        ];
      };
  };

  nix.gc.automatic = false;

  #   services.vsftpd = {
  #     enable = true;
  #     #forceLocalLoginsSSL = true;
  #     #forceLocalDataSSL = true;
  #     userlistDeny = false;
  #     localUsers = true;
  #     #rsaCertFile = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/cert.pem";
  #     #rsaKeyFile = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/key.pem";
  #     userlist = [ config.users.users.mainUser.name ];
  #     extraConfig = ''
  #       pasv_enable=Yes
  #       pasv_min_port=10090
  #       pasv_max_port=10100
  #     '';
  #     writeEnable = true;
  #   };
  #   networking.firewall.allowedTCPPorts = [ 21 ];
  #   networking.firewall.allowedTCPPortRanges = [
  #     { from = 10090; to = 10100; }
  #   ];

  nix = {
    # buildMachines = [
    #   {
    #     hostName = universe.hosts.ws1.nets.bs53lan.ip4.addr;
    #     sshUser = "enno";
    #     sshKey = "/tmp/id_ed25519";
    #     systems = [ "x86_64-linux" ];
    #     maxJobs = 48;
    #   }
    # ];
    trustedUsers = [ "root" "enno" ];
    # distributedBuilds = true;
    # extraOptions = ''
    #   builders-use-substitutes = true
    # '';
  };

  #  # https://github.com/anbox/anbox/issues/253
  #  # use:
  #  # sudo mkdir -p rootfs-overlay/system/usr/keychars
  #  # sudo cp Generic_de_DE.kcm rootfs-overlay/system/usr/keychars/anbox-keyboard.kcm
  # virtualisation.anbox = {
  #   enable = true;
  # };
  # programs.adb.enable = true;
  # users.users.mainUser.extraGroups = [ "adbusers" ];

  ptsd.wireguard.networks.nwvpn.client.allowedIPs = [ "192.168.178.0/24" ];

  # systemd.services.disable-bluetooth = {
  #   description = "Disable Bluetooth after boot to save energy";
  #   wantedBy = [ "multi-user.target" ];
  #   script = "${pkgs.utillinux}/bin/rfkill block bluetooth";
  # };

  # fonts.fontconfig = {
  #   antialias = false;
  #   hinting.enable = false;
  #   subpixel.rgba = "none";
  # };

  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.printing.drivers = with pkgs; [
    brlaser
    gutenprint
    gutenprintBin
    samsungUnifiedLinuxDriver
    splix
  ];

  services.avahi.enable = true;

  services.logind.lidSwitch = "suspend-then-hibernate";
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=12h
  '';

  services.udev.extraRules = ''
    # Suspend the system when battery level drops to 5% or lower
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
  '';

  networking = {
    hostName = "tp1";
    hosts = {
      #  "127.0.0.1" = [ "fritz.box" ];
      #"192.168.178.11" = [ "apu1.host.nerdworks.de" "apu1" ];
      #"192.168.178.33" = [ "prt1.host.nerdworks.de" "prt1" ];
    };

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

    firewall.interfaces."${virshNatIf}" = {
      allowedTCPPorts = [ 53 631 445 139 ];
      allowedUDPPorts = [ 53 67 68 546 547 137 138 ];
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
          Address = "${virshNatIpPrefix}.1/24";
        };
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  environment.systemPackages = with pkgs; [
    powertop
    networkmanagerapplet
    samba
    home-manager
    efibootmgr
    efitools
    tpm2-tools

    (writeShellScriptBin "activate-da-home-again" ''
      ${config.home-manager.users.mainUser.home.activationPackage}/activate
    '')
  ];

  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      hosts allow = ${virshNatIpPrefix}.0/24 # virshNat network
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      home = {
        path = "/home/enno";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  ptsd.wireguard.networks = {
    dlrgvpn = {
      enable = false;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      client.allowedIPs = [ "192.168.168.0/24" ];
      routes = [
        { routeConfig = { Destination = "192.168.168.0/24"; }; }
      ];
      keyname = "nwvpn.key";
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false; # will be socket-activated
    };
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
      qemuRunAsRoot = false; # TODO: test permissions
    };
  };

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/FPV" = {
        label = "FPV";
        id = "xxdwi-yom6n";
        devices = [ "nas1" "tp1-win10" "ws1" "ws1-win10" "ws1-win10n" ];
      };
      # "/home/enno/Hörspiele" = {
      #   id = "rqnvn-lmhcm";
      #   devices = [ "ext-arvid" "nas1" ];
      #   type = "sendonly";
      # };
      "/home/enno/LuNo" = {
        label = "LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1" "tp2" "ws1" ];
      };
      "/home/enno/Pocket" = {
        label = "Pocket";
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1-win10" "ws1" "ws1-win10" "ws2" ];
      };
      "/home/enno/Scans" = {
        label = "Scans";
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "ws1" "ws2" "iph3" ];
      };
      "/home/enno/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "nuc1" "ws1" "ws2" ];
      };
      "/home/enno/iOS" = {
        label = "iOS";
        id = "qm9ln-btyqu";
        devices = [ "iph3" ];
      };
      # "/home/enno/repos-ws1" = {
      #   id = "jihdi-qxmi3";
      #   devices = [ "nas1" "ws1" ];
      #   type = "receiveonly";
      #   label = "repos-ws1";
      # };
    };
  };
}
