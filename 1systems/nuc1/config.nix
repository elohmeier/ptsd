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
          ./home.nix
        ];
      };
  };

  # fonts.fontconfig = {
  #   antialias = false;
  #   hinting.enable = false;
  #   subpixel.rgba = "none";
  # };

  ptsd.nwtraefik = {
    enable = true;
    entryPoints = {
      "loopback6-http" = {
        address = "[::1]:80";
        http.redirections.entryPoint = {
          to = "loopback6-https";
          scheme = "https";
          permanent = true;
        };
      };
      "loopback6-https".address = "[::1]:443";
    };
    #logLevel = "debug";
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    hostName = "nuc1";
    interfaces.eno1.useDHCP = true;
  };

  systemd.network.networks."40-eno1".networkConfig = {
    ConfigureWithoutCarrier = true;
  };

  ptsd.wireguard.networks.nwvpn = {
    # SIP
    client.allowedIPs = [ "192.168.178.1/32" ];
    routes = [
      { routeConfig = { Destination = "192.168.178.1/32"; }; }
    ];
  };

  networking.networkmanager = {
    enable = true;
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

  ptsd.vdi-container = {
    enable = true;
    extIf = "wlan0";
    #extIf = "eno1";
  };

  services.printing.enable = true;
  services.avahi.enable = true;

  ptsd.nwsyncthing = {
    enable = true;
    folders = {
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "htz2" "nas1-st-enno" "nuc1" "tp1" "tp1-win10" "ws1" "ws1-win10" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1-st-enno" "tp1" "ws1" ];
      };
    };
  };

  services.xserver = {

    # turn on numlock in X11 by default
    displayManager.lightdm.extraSeatDefaults =
      "greeter-setup-script=${pkgs.numlockx}/bin/numlockx on";

    xrandrHeads = [
      {
        output = "HDMI-2";
        primary = true; # fixes missing tray in i3bar
        #monitorConfig = ''Option "Position" "0 360"'';
        monitorConfig = ''Option "Position" "0 0"'';
      }
      {
        output = "HDMI-1";
        monitorConfig = ''
          Option "Position" "1920 0"
          Option "PreferredMode" "2560x1440"
        '';
      }
    ];
  };

  services.zfs.autoScrub.enable = true;

  ptsd.nwbackup-server = {
    enable = true;
    zpool = "nw28";
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
      qemuRunAsRoot = false;
    };
  };

  ptsd.pulseaudio.virtualAudioMixin = {
    enable = true;
    microphone = "alsa_input.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.mono-fallback";
    speakers = "alsa_output.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.analog-stereo";
  };
}
