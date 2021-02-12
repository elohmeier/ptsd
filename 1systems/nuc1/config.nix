{ config, lib, pkgs, ... }:
let
  todoistSecrets = import <secrets/todoist.nix>;
  desktopSecrets = import <secrets-shared/desktop.nix>;
in
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

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    mode = "sway";
    trayOutput = "HDMI-A-2";
    fontMono = "Cozette";
    enablePipewire = true;
    nwi3status = {
      #todoistApiKey = todoistSecrets.todoistApiKey;
      openweathermapApiKey = desktopSecrets.openweathermapApiKey;
    };
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
      # public is a separate drive, see ./physical.nix
      public = {
        path = "/home/enno/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
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
    enable = false;
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
        output = "HDMI-1";
        primary = true; # fixes missing tray in i3bar
      }
      {
        output = "HDMI-2";
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

  services.octoprint = {
    enable = true;
    host = "127.0.0.1";
    plugins = plugins: [
      plugins.octoklipper
      (plugins.callPackage <ptsd/5pkgs/octoprint-plugins/bedlevelvisualizer.nix> { })
      (plugins.callPackage <ptsd/5pkgs/octoprint-plugins/m73progress.nix> { })
    ];
    extraConfig = {
      plugins = {
        _disabled = [
          "announcements"
          "tracking"
          "backup"
          "discovery"
          "errortracking"
          "firmware_check"
          "softwareupdate"
          "virtual_printer"
        ];
        bedlevelvisualizer.command = ''
          BED_MESH_CALIBRATE
          @BEDLEVELVISUALIZER
          BED_MESH_OUTPUT
        '';
        klipper = {
          configuration.configpath = "/etc/klipper.cfg";
          connection.port = "/run/klipper/tty";
        };
      };
    };
  };

  services.klipper = {
    enable = true;
    octoprintIntegration = true;
    settings = {

      stepper_x = {
        step_pin = "PD7";
        dir_pin = "!PC5";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^PC2";
        position_endstop = "0";
        position_max = "235";
        homing_speed = "50";
      };

      stepper_y = {
        step_pin = "PC6";
        dir_pin = "!PC7";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^PC3";
        position_endstop = "0";
        position_max = "235";
        homing_speed = "50";
      };

      stepper_z = {
        step_pin = "PB3";
        dir_pin = "PB2";
        enable_pin = "!PA5";
        microsteps = "16";
        rotation_distance = "8";
        endstop_pin = "probe:z_virtual_endstop";
        position_max = "250";
        # position_min="-2"; # only for calibration
      };

      extruder = {
        max_extrude_only_distance = "100.0";
        step_pin = "PB1";
        dir_pin = "PB0";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "9.524 # 336 steps/mm as specified in matrix extruder doc";
        nozzle_diameter = "0.400";
        filament_diameter = "1.750";
        heater_pin = "PD5";
        sensor_type = "EPCOS 100K B57560G104F";
        sensor_pin = "PA7";
        control = "pid";
        pid_Kp = "21.527";
        pid_Ki = "1.063";
        pid_Kd = "108.982";
        min_temp = "0";
        max_temp = "250";
      };

      heater_bed = {
        heater_pin = "PD4";
        sensor_type = "EPCOS 100K B57560G104F";
        sensor_pin = "PA6";
        control = "pid";
        pid_Kp = "54.027";
        pid_Ki = "0.770";
        pid_Kd = "948.182";
        min_temp = "0";
        max_temp = "130";
      };

      fan = {
        pin = "PB4";
      };

      mcu = {
        serial = "/dev/ttyUSB0";
      };

      printer = {
        kinematics = "cartesian";
        max_velocity = "300";
        max_accel = "3000";
        max_z_velocity = "5";
        max_z_accel = "100";
      };

      display = {
        lcd_type = "st7920";
        cs_pin = "PA3";
        sclk_pin = "PA1";
        sid_pin = "PC1";
        encoder_pins = "^PD2, ^PD3";
        click_pin = "^!PC0";
      };

      bltouch = {
        sensor_pin = "^PC4";
        control_pin = "PA4";
        x_offset = "-38";
        y_offset = "1";
        z_offset = "1.145"; # calibrated 05.02.2021
        speed = "5.0";
      };

      safe_z_home = {
        home_xy_position = "120,120";
        z_hop = "10.0";
      };

      bed_mesh = {
        speed = "200";
        horizontal_move_z = "5";
        mesh_min = "10,30";
        mesh_max = "180, 230";
        probe_count = "3,3";
      };

      "gcode_macro G29" = {
        gcode = "\n BED_MESH_CALIBRATE";
      };
    };
  };
}
