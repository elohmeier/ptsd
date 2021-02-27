{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
  virshNatIpPrefix = "192.168.197"; # "XXX.XXX.XXX" without last block
  virshNatIf = "virsh-nat";
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/awscli.nix>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/gcalcli.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/stateless-root.nix>
    <ptsd/2configs/zsh-enable.nix>

    <ptsd/2configs/themes/fraam.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/nextcloud-client.nix>
    <ptsd/2configs/prometheus/node.nix>

    <secrets-shared/nwsecrets.nix>
    <ptsd/2configs/home-secrets.nix>

    <home-manager/nixos>
  ];

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    mode = "sway";
    #fontMono = "Cozette";
    trayOutput = "eDP-1";
    terminalConfig = "alacritty";
    waybar.enable = true;
    profiles = [
      "admin"
      "dev"
      "kvm"
      "media"
      "office"
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

    interfaces = {
      "${virshNatIf}".ipv4.addresses = [{ address = "${virshNatIpPrefix}.1"; prefixLength = 24; }];
    };

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
        id = "xxdwi-yom6n";
        devices = [ "htz2" "nas1-st-enno" "tp1-win10" "ws1" "ws1-win10" "ws1-win10n" ];
      };
      # "/home/enno/Hörspiele" = {
      #   id = "rqnvn-lmhcm";
      #   devices = [ "ext-arvid" "nas1-st-enno" ];
      #   type = "sendonly";
      # };
      "/home/enno/LuNo" = {
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1-st-enno" "nas1-st-luisa" "tp2" "ws1" ];
      };
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "htz2" "nas1-st-enno" "nuc1" "tp1-win10" "ws1-win10" ];
      };
      "/home/enno/Scans" = {
        id = "ezjwj-xgnhe";
        devices = [ "nas1-st-enno" "ws1" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1-st-enno" "nuc1" "ws1" ];
      };
      # "/home/enno/repos-ws1" = {
      #   id = "jihdi-qxmi3";
      #   devices = [ "nas1-st-enno" "ws1" ];
      #   type = "receiveonly";
      #   label = "repos-ws1";
      # };
    };
  };
}
