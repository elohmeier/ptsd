with import <ptsd/lib>;
{ config, lib, pkgs, ... }:
let
  lanIf1 = "enp1s0";
  lanIf2 = "enp2s0";
  lanIf3 = "enp3s0";
  brlanIf = "brlan";
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <ptsd/2configs/prometheus/node.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu3";
    bridges."${brlanIf}".interfaces = [ lanIf1 lanIf2 lanIf3 ];
    interfaces = {
      "${brlanIf}" = {
        useDHCP = true;
        ipv4.routes = [
          # route to hetzner storagebox via DSL
          {
            address = "136.243.27.72";
            prefixLength = 32;
            via = "192.168.1.1";
          }
        ];
      };
    };
    firewall = {
      interfaces = {
        "${brlanIf}" = {
          allowedTCPPorts = [ 445 139 ];
          allowedUDPPorts = [ 137 138 ];
        };
        "nwvpn" = {
          allowedTCPPorts = [ 445 139 ];
          allowedUDPPorts = [ 137 138 ];
        };
      };

      # reduce noise coming from ppp if
      # logRefusedConnections = false;

      # useful for debugging
      #logRefusedPackets = true;
      #logRefusedUnicastsOnly = false;
      #logReversePathDrops = true;
    };
    nat = {
      enable = true;
      externalInterface = "ppp0";
      internalInterfaces = [ brlanIf ];
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  systemd.network.networks = {
    "40-${brlanIf}" = {
      dhcpV4Config.UseRoutes = false; # allows pppd to set default route
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-${lanIf1}" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-${lanIf2}" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-${lanIf3}" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
    "40-ppp0" = {
      name = "ppp0";
      networkConfig = {
        KeepConfiguration = "yes"; # accept config set by pppd
      };
    };
  };

  ptsd.wireguard.networks.svbvpn = {
    enable = true;
    ip = universe.hosts."${config.networking.hostName}".nets.svbvpn.ip4.addr;
  };

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      hosts allow = 192.168.0.0/16 191.18.19.0/24
      hosts deny = 0.0.0.0/0

      # disable cups integration
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
    '';
    shares = {
      SVB-Koetter = {
        path = "/data/SVB-Koetter";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "force group" = "svb";
        "create mask" = "0770";
        "directory mask" = "0770";
      };
      Scans = {
        path = "/data/Scans";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "force group" = "svb";
        "create mask" = "0770";
        "directory mask" = "0770";
      };
    };
  };

  services.snapper.configs =
    let
      extraConfig = ''
        TIMELINE_CREATE=yes
        TIMELINE_CLEANUP=yes
      '';
    in
    {
      SVB-Koetter = {
        subvolume = "/data/SVB-Koetter";
        inherit extraConfig;
      };
      Scans = {
        subvolume = "/data/Scans";
        inherit extraConfig;
      };
    };

  users.groups.svb = { gid = 997; };
  users.users = let group = "svb"; in
    {
      "c.koetter" = { uid = 1002; inherit group; };
      "m.nieporte" = { uid = 1003; inherit group; };
      "scanner" = { uid = 1004; inherit group; };
    };

  # useful commands for `screen /dev/ttyUSB0 115200`
  # AT+CPIN? //Check if SIM is PIN locked
  # AT+COPS?
  # AT+CFUN? //Check module status
  # ATI //Check firmware version.
  services.pppd =
    let
      chatfile = pkgs.writeText "ppp.chat" ''
        ABORT 'BUSY'
        ABORT 'NO CARRIER'
        ABORT 'VOICE'
        ABORT 'NO DIALTONE'
        ABORT 'NO DIAL TONE'
        ABORT 'NO ANSWER'
        ABORT 'DELAYED'
        REPORT CONNECT
        TIMEOUT 10
        ''' 'ATQ0'
        'OK-AT-OK' 'ATZ'
        TIMEOUT 3
        'OK-AT-OK' 'ATI'
        'OK' 'AT+CFUN=1'
        'OK' 'AT+CMEE=2'
        'OK' 'AT+CSQ'
        'OK' 'AT+CGDCONT=1,"IP","internet.telekom"'
        TIMEOUT 10
        'OK' 'ATDT*99***1#'
        TIMEOUT 3
        CONNECT '''
      '';
    in
    {
      enable = true;
      # see https://telekomhilft.telekom.de/t5/Blog/Neuer-IPv6-Zugang-zum-mobilen-Internet-im-Netz-der-Telekom/ba-p/4254741
      # and https://github.com/blu3bird/OpenHybrid
      peers.telekom = {
        enable = true;
        autostart = true;
        config = ''
          /dev/ttyUSB0
          115200

          # Login settings
          noauth
          hide-password
          user "congstar"
          remotename telekom
          ipparam telekom

          # Connection settings
          connect "${pkgs.ppp}/bin/chat -v -f ${chatfile}"
          persist
          maxfail 0
          holdoff 5
          nodeflate

          # IP settings
          noipdefault
          noipv6
          defaultroute

          # Increase debugging level
          debug
        '';
      };
    };

  environment.etc."ppp/pap-secrets" =
    {
      text = ''"congstar" telekom "cs"'';
      mode = "0400";
    };

  environment.systemPackages = with pkgs; [ tmux htop bridge-utils vim screen samba iftop ];

  programs.mosh.enable = true;

  environment.variables = {
    BORG_BASE_DIR = "/var/lib/borg";
    BORG_REPO = "ssh://u255166@u255166.your-storagebox.de:23/./backups/apu3";
    BORG_PASSCOMMAND = "cat ${toString <secrets>}/nwbackup.borgkey";
  };

  services.borgbackup.jobs.hetzner = {
    paths = [ "/data" "/var/lib" "/var/src" ];
    exclude = [ "/*/.snapshots" "/var/lib/borg" ];
    repo = "ssh://u255166@u255166.your-storagebox.de:23/./backups/apu3";
    environment = {
      BORG_BASE_DIR = "/var/lib/borg";
    };
    readWritePaths = [ "/var/lib/borg" ];
    encryption = {
      mode = "repokey";
      passCommand = "cat ${toString <secrets>}/nwbackup.borgkey";
    };
    compression = "auto,lzma,6";
    doInit = false;
    extraCreateArgs = "--stats --exclude-caches";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };

  ptsd.secrets.files = {
    "nwbackup.id_ed25519" = {
      path = "/root/.ssh/id_ed25519";
    };
  };
}
