{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/awscli.nix>
      <ptsd/2configs/cli-tools.nix>
      <ptsd/2configs/gcalcli.nix>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/stateless-root.nix>
      <ptsd/2configs/zsh-enable.nix>

      <ptsd/2configs/themes/fraam.nix>
      <ptsd/2configs/nextcloud-client.nix>
      <ptsd/2configs/prometheus/node.nix>

      <secrets-shared/nwsecrets.nix>
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

  ptsd.desktop = {
    enable = true;
    mode = "sway";
    trayOutput = "HDMI-A-2";
    terminalConfig = "alacritty";
    fontMono = "Cozette";
  };

  # set low priority for nix daemon to ensure desktop responsiveness while updating
  nix = {
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
  };

  boot.kernel.sysctl = {
    # set higher than usual dirty/writeback ratio to be able to 
    # buffer sysupgrade in ram and keep desktop responsiveness
    "vm.dirty_ratio" = 75;
    "vm.dirty_background_ratio" = 50;
  };

  hardware.printers = {
    ensureDefaultPrinter = "HL5380DN";
    ensurePrinters = [
      {
        name = "HL5380DN";
        deviceUri = "socket://192.168.1.2:9100";
        location = "fraam office";
        model = "drv:///sample.drv/generpcl.ppd";
        ppdOptions = {
          PageSize = "A4";
          Resolution = "600dpi";
          InputSlot = "Auto";
          MediaType = "PLAIN";
        };
      }
    ];
  };

  ptsd.cups-airprint = {
    enable = true;
    lanDomain = "lan";
    listenAddress = "192.168.1.121:631";
    printerName = "HL5380DN";
  };

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.1.0/24
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

  # workaround AirPrint printer not showing up after boot
  systemd.services.avahi-daemon.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";

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

    firewall.interfaces.wlan0 = {
      # samba/cups ports
      allowedTCPPorts = [ 631 445 139 ];
      allowedUDPPorts = [ 631 137 138 ];
    };
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
    enable = false;
    #microphone = "alsa_input.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.mono-fallback";               
    speakers = "alsa_output.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.analog-stereo";

    microphone = "alsa_input.usb-046d_HD_Pro_Webcam_C920_3A87F0DF-02.analog-stereo";
    aecArgs = "beamforming=1 mic_geometry=-0.04,0,0,0.04,0,0 noise_suppression=1 analog_gain_control=0 digital_gain_control=1 agc_start_volume=200";
  };
}
