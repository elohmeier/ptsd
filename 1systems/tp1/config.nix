{ config, lib, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix

    ../../2configs/themes/black.nix
    ../../2configs/printers/hl5380dn.nix
    ../../2configs/prometheus/node.nix

    ../../2configs/profiles/bs53.nix
    ../../2configs/profiles/workstation

    ./modules/syncthing.nix
  ];

  # backup after boot
  systemd.timers.borgbackup-job-nwbackup-nas1.timerConfig.OnBootSec = "3m";

  services.gpm.enable = true;

  ptsd.nwbackup = {
    paths = [ "/home" ];
  };

  services.hardware.bolt.enable = true;

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    trayOutput = "eDP-1";
    fontSize = 12.0;

    baresip = {
      enable = true;
      netInterface = "nwvpn";
    };
  };

  home-manager.users.mainUser = { ... }:
    {
      home.stateVersion = "20.09";
      wayland.windowManager.sway = {
        config.input."1739:0:Synaptics_TM3381-002".events = "disabled";
      };
    };


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

  # systemd.services.disable-bluetooth = {
  #   description = "Disable Bluetooth after boot to save energy";
  #   wantedBy = [ "multi-user.target" ];
  #   script = "${pkgs.utillinux}/bin/rfkill block bluetooth";
  # };

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

    nat.externalInterface = "wlan0";
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  environment.systemPackages = with pkgs; [
    # run-kali-vm
    # run-win-vm
    powertop
    samba
    home-manager
    efibootmgr
    efitools
    tpm2-tools

    (writeShellScriptBin "activate-da-home-again" ''
      ${config.home-manager.users.mainUser.home.activationPackage}/activate
    '')
  ];

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

    nwvpn = {
      # SIP
      #client.allowedIPs = [ "192.168.178.1/32" ];
      #routes = [
      #  { routeConfig = { Destination = "192.168.178.1/32"; }; }
      #];
    };
  };

  # faster boot
  systemd.services.NetworkManager-wait-online.enable = false;
  services.samba.enableNmbd = false;

  services.samba.shares = {
    scans = {
      path = "/home/enno/Scans";
      browseable = "no";
      "read only" = "no";
      "guest ok" = "no";
      "force group" = "users";
      "force user" = "enno";
    };
  };

  # Samba
  networking.firewall.interfaces."wlan0".allowedTCPPorts = [ 445 139 ];

  users = {
    users.scanner = { group = "scanner"; isSystemUser = true; };
    groups.scanner = { };
  };

  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "faraday" ];
  #   ensureUsers = [{
  #     name = "enno";
  #     ensurePermissions."DATABASE faraday" = "ALL PRIVILEGES";
  #   }];
  # };
}
