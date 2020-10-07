{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/stateless-root.nix>

    <ptsd/2configs/baseX.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    #<ptsd/2configs/dovecot.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/nextcloud-client.nix>
    <ptsd/2configs/prometheus/node.nix>

    <secrets-shared/nwsecrets.nix>
    <client-secrets/dbk/vdi.nix>
    <ptsd/2configs/home-secrets.nix>

    <home-manager/nixos>
  ];

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home-common.nix
        ];

        ptsd.urxvt.theme = "solarized_light";
      };
  };

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

  #boot.plymouth.enable = true;

  #  # https://github.com/anbox/anbox/issues/253
  #  # use:
  #  # sudo mkdir -p rootfs-overlay/system/usr/keychars
  #  # sudo cp Generic_de_DE.kcm rootfs-overlay/system/usr/keychars/anbox-keyboard.kcm
  # virtualisation.anbox = {
  #   enable = true;
  # };
  # programs.adb.enable = true;
  # users.users.mainUser.extraGroups = [ "adbusers" ];

  # reduce the noise
  ptsd.nwtelegraf.enable = lib.mkForce false;

  ptsd.wireguard.networks.nwvpn.client.allowedIPs = [ "192.168.178.0/24" ];

  ptsd.vdi-container = {
    enable = true;
    extIf = "wlan0";
  };

  systemd.services.disable-bluetooth = {
    description = "Disable Bluetooth after boot to save energy";
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.utillinux}/bin/rfkill block bluetooth";
  };

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
  };

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

  environment.systemPackages = with pkgs; [
    powertop
    networkmanagerapplet
    samba
    home-manager
    efibootmgr
    efitools
    tpm2-tools
  ];

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.101.0/24 # host-virsh network
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

  networking.firewall.interfaces.virbr2 = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # will be socket-activated
  virtualisation.libvirtd.enable = true;

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/FPV" = {
        id = "xxdwi-yom6n";
        devices = [ "htz2" "nas1-st-enno" "tp1-win10" "ws1" "ws1-win10" "ws1-win10n" ];
      };
      "/home/enno/LuNo" = {
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1-st-enno" "nas1-st-luisa" "nuc1" "tp2" "ws1" ];
      };
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "htz2" "nas1-st-enno" "nuc1" "tp1" "tp1-win10" "ws1-win10" ];
      };
      "/home/enno/Scans" = {
        id = "ezjwj-xgnhe";
        devices = [ "nas1-st-enno" "ws1" ];
      };
      "/home/enno/repos-ws1" = {
        id = "jihdi-qxmi3";
        devices = [ "nas1-st-enno" "ws1" ];
        type = "receiveonly";
        label = "repos-ws1";
      };
    };
  };
}
