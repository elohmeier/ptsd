{ config, lib, pkgs, ... }:
with lib;
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
    ../../2configs/prometheus/node.nix

    # 
    # ../../2configs/home-secrets.nix

    ../../2configs/nvidia-headless.nix
  ];

  ptsd.photoprism = {
    enable = true;
    httpHost = "127.0.0.1";
    httpPort = 2342;
    siteUrl = "http://127.0.0.1/";
    dataDirectory = "/mnt/photos/photos";
    cacheDirectory = "/mnt/photos/photoprism-cache";
    user = "enno";
    group = "users";
    autostart = false;
  };

  services.usbguard = {
    enable = false;
    IPCAllowedUsers = [ "enno" "root" ];

    # generated using `usbguard generate-policy` & edited
    rules = ''
      allow id 1d6b:0002 serial "0000:2a:00.1" name "xHCI Host Controller" hash "7LbED1GqzetHdUEZDcU3D8XZQDP/YnFMhAimHAESkbc=" parent-hash "+vZ8CHLTZn4IvyjR2V7r5H+abDxkcncYE6vL2axVWvQ=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:2a:00.1" name "xHCI Host Controller" hash "advuFkDyZlv4Ibuzeh6DyyLwXwYHO4H3qo/VwazQTyM=" parent-hash "+vZ8CHLTZn4IvyjR2V7r5H+abDxkcncYE6vL2axVWvQ=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:2a:00.3" name "xHCI Host Controller" hash "vawpCqjGEnZlurUwVcF9OmK3uHHbR+bDL2dxfeB0YtU=" parent-hash "jAgnD8mqIyEYjHCzCdMacLXGa7T/W9QEMF2NUPf1NU8=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:2a:00.3" name "xHCI Host Controller" hash "Jw0VE3YYVEKSw9aKBD0nOs7XZzQCd3DPI0GvLp7P+Bs=" parent-hash "jAgnD8mqIyEYjHCzCdMacLXGa7T/W9QEMF2NUPf1NU8=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:2d:00.2" name "xHCI Host Controller" hash "a1ohYJvgNFtB0scybuUYViVOTAfycbXNIBQpjTHTXDo=" parent-hash "hwRjSoLx859h0ekQihZXoOOcvH1sNYO5Be/W5QADPPw=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:2d:00.2" name "xHCI Host Controller" hash "kV90I4+CdfIkiHCdBmlOUtIJlZF+3DN8jlllN2sBkjU=" parent-hash "hwRjSoLx859h0ekQihZXoOOcvH1sNYO5Be/W5QADPPw=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:2f:00.3" name "xHCI Host Controller" hash "FJMky+ph03HBWDrD+oRitafrQikQKNR8n4h1MaHV68o=" parent-hash "Ol7ZwZpUoDxZCwmqn/CwYMBm9GAl4zTMDzR2w2wdwqo=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:2f:00.3" name "xHCI Host Controller" hash "mStuRxuVKXIlG/+/sHtcTH4iCf/Rw/t7BKj5TG194cU=" parent-hash "Ol7ZwZpUoDxZCwmqn/CwYMBm9GAl4zTMDzR2w2wdwqo=" with-interface 09:00:00 with-connect-type ""
      allow id 046d:c52b serial "" name "USB Receiver" hash "2jD4laupwOlO9G4MODYJC0mRE0Z4v+lbYeEUvdLrZPg=" parent-hash "7LbED1GqzetHdUEZDcU3D8XZQDP/YnFMhAimHAESkbc=" via-port "1-5" with-interface { 03:01:01 03:01:02 03:00:00 } with-connect-type "hotplug"
      allow id 046d:0892 serial "F31F411F" name "HD Pro Webcam C920" hash "tH2q1g+bWcXRIVQq7svH20hfcLZ/ezVlgl4TjasaM7M=" parent-hash "7LbED1GqzetHdUEZDcU3D8XZQDP/YnFMhAimHAESkbc=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 } with-connect-type "hotplug"
      allow id 0a5c:21e8 serial "5CF370938B37" name "BCM20702A0" hash "e28H2zxtRh799KwHL5QdsG4+bU4X4gmJClQyfQPE7Ls=" parent-hash "vawpCqjGEnZlurUwVcF9OmK3uHHbR+bDL2dxfeB0YtU=" with-interface { ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:01:01 ff:ff:ff fe:01:01 } with-connect-type "hotplug"
      allow id 1462:7c37 serial "A02019050806" name "MYSTIC LIGHT " hash "FWs3ySVTvrqTDwDSre1c8/i24p9ge2mJEy4Zz6nww+E=" parent-hash "vawpCqjGEnZlurUwVcF9OmK3uHHbR+bDL2dxfeB0YtU=" with-interface 03:00:00 with-connect-type "unknown"
      allow id 05e3:0608 serial "" name "USB2.0 Hub" hash "yIjW/Cyf9Hw+fZCT+H0TSxdcxuaT0ynygaCDFwdnGlw=" parent-hash "vawpCqjGEnZlurUwVcF9OmK3uHHbR+bDL2dxfeB0YtU=" via-port "3-6" with-interface 09:00:00 with-connect-type "unknown"
      allow id 043e:9a46 serial "" name "USB2.1 Hub" hash "hHHED0h2zzQlpF++B6gljcZJuXGxQQeGpVETLDYRg0g=" parent-hash "a1ohYJvgNFtB0scybuUYViVOTAfycbXNIBQpjTHTXDo=" via-port "5-1" with-interface { 09:00:01 09:00:02 } with-connect-type "unknown"
      allow id 045e:082c serial "603912700821" name "Microsoft Ergonomic Keyboard" hash "6cBqtPpb456flyfj3raspZ1sbK8vmPRlURWX/Rq8kbs=" parent-hash "FJMky+ph03HBWDrD+oRitafrQikQKNR8n4h1MaHV68o=" with-interface { 03:01:01 03:00:00 } with-connect-type "hotplug"
      allow id 0499:1730 serial "" name "Steinberg UR44C" hash "U+za8vS9mmBYXmkJPmJTaWcHh6HOaP2Gku1R9/C4+oc=" parent-hash "mStuRxuVKXIlG/+/sHtcTH4iCf/Rw/t7BKj5TG194cU=" via-port "8-1" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 01:03:00 ff:01:20 ff:02:20 ff:02:20 ff:02:20 ff:02:20 ff:03:ff ff:ff:ff } with-connect-type "hotplug"
      allow id 1050:0407 serial "" name "YubiKey OTP+FIDO+CCID" hash "UP/fS/jaI4Elg4Fej+gf1QXLWPleJ54MqMtO16eSmr8=" with-connect-type "hotplug"
      allow id 058f:8468 serial "158F84688461" name "Mass Storage Device" hash "uT5w4BkZnTZg0EJeCm1cD9vhwaS9V54ojFd2eNtaZqY=" parent-hash "hHHED0h2zzQlpF++B6gljcZJuXGxQQeGpVETLDYRg0g=" with-interface 08:06:50 with-connect-type "unknown"
      allow id 043e:9a48 serial "" name "" hash "xN00U9+GRxTZL94NiMZsn7iHvyMyqf12eqLMl/QyyZg=" parent-hash "hHHED0h2zzQlpF++B6gljcZJuXGxQQeGpVETLDYRg0g=" via-port "5-1.4" with-interface 09:00:00 with-connect-type "unknown"
      allow id 043e:9a42 serial "" name "USB Audio" hash "/MskUBZYKp1Sza5dwaI5pn0Bg02qL1EUJiPQzOzLRYc=" parent-hash "xN00U9+GRxTZL94NiMZsn7iHvyMyqf12eqLMl/QyyZg=" via-port "5-1.4.1" with-interface { 01:01:00 01:02:00 01:02:00 } with-connect-type "unknown"
      allow id 043e:9a40 serial "" name "USB Controls" hash "2lvYZ07xBCw2kaqrCiFdFhcXkHBZyRdOztpWZqsX3QA=" parent-hash "xN00U9+GRxTZL94NiMZsn7iHvyMyqf12eqLMl/QyyZg=" via-port "5-1.4.4" with-interface { 03:00:00 03:00:00 03:00:00 } with-connect-type "unknown"
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.blacklistedKernelModules = [
    "nouveau"
    # "nvidia"
    # "nvidia_drm"
    # "nvidia_uvm"
    # "nvidia_modeset"
    # "i2c_nvidia_gpu"
  ];
  boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
  '';

  # systemd.services.wol-eth0 = {
  #   description = "Wake-on-LAN for enp39s0";
  #   requires = [ "network.target" ];
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp39s0 wol g"; # magicpacket
  #   };
  # };


  # sample to pass USB access to VM
  # see https://github.com/NixOS/nixpkgs/issues/27199
  # SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="90cc", GROUP="users", MODE="0777"

  ptsd.cli = {
    enable = true;
    defaultShell = "nushell";
  };

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    waybar.co2 = true;
    profiles = [
      "3dprinting"
      "admin"
      "dev"
      "fpv"
      "games"
      "kvm"
      "media"
      "office"
      "sec"
    ];
    autolock.enable = false;
    baresip = {
      enable = true;

      # QC35
      # audioPlayer = "bluez_sink.04_52_C7_0C_C1_61.headset_head_unit";
      # audioSource = "bluez_source.04_52_C7_0C_C1_61.headset_head_unit";

      # Steinberg
      audioPlayer = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";

      # Cam
      audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.pro-input-0";

      # Cam AEC
      #audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo.echo-cancel";
      #audioSource = "vsink_fx_mic.monitor";

      audioAlert = "alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo";
    };
  };

  nix.trustedUsers = [ "root" "enno" ];
  #hardware.steam-hardware.enable = true;

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  ptsd.nwbackup = {
    enable = true;
    repos.nas1 = "borg-${config.networking.hostName}@192.168.178.12:.";
    paths = [
      "/home"
    ];
  };

  services.avahi.enable = true;

  networking = {
    hostName = "ws1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.eth0.useDHCP = true; # wifi if

    #bridges.br0.interfaces = [ "enp39s0" ];
    #interfaces.br0.useDHCP = true;

    # hosts."10.129.127.250" = [ "s3.bucket.htb" "bucket.htb" ];

    wireless.iwd.enable = true;

    firewall.interfaces = {
      "${virshNatIf}" = {
        allowedTCPPorts = [ 53 631 445 139 ];
        allowedUDPPorts = [ 53 67 68 546 547 137 138 ];
      };

      eth0 = {
        allowedTCPPorts = [ 3389 ]; # for optional rdp forwarding
      };
    };

    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ virshNatIf ];
    };
  };

  ptsd.secrets.files."Bundesdatenschutzzentrale 5GHz.psk" = {
    path = "/var/lib/iwd/Bundesdatenschutzzentrale 5GHz.psk";
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
      "40-eth0" = {
        routes = [
          {
            routeConfig = {
              Destination = "${universe.hosts.nas1.nets.nwvpn.ip4.addr}/32";
              Gateway = universe.hosts.nas1.nets.bs53lan.ip4.addr;
              GatewayOnLink = "yes";
            };
          }
        ];
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    #   extraConfig = ''
    #     [Resolve]
    #     DNS=127.0.0.1:5053
    #     Domains=~htb
    #   '';
  };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [
    "ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:enp39s0:off"
    "mitigations=off" # make linux fast again
    "amd_iommu=on"
    "video=vesafb:off"
    "video=efifb:off"
  ];

  # ptsd.wireguard.networks = {
  #   dlrgvpn = {
  #     enable = true;
  #     ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
  #     client.allowedIPs = [ "192.168.168.0/24" ];
  #     routes = [
  #       { routeConfig = { Destination = "192.168.168.0/24"; }; }
  #     ];
  #     keyname = "nwvpn.key";
  #   };
  # };

  # default: poweroff
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    RuntimeDirectorySize=80%
  '';

  # *** NVIDIA Driver
  # services.xserver = {
  #   videoDrivers = [ "nvidia" ];
  #   xrandrHeads = [
  #     { output = "DP-0"; primary = true; }
  #     {
  #       output = "USB-C-0";
  #       # monitorConfig = ''Option "Rotate" "left"'';
  #     }
  #   ];
  # };
  # # compensate X11 shutdown problems, probably caused by nvidia driver
  # systemd.services.display-manager.postStop = ''
  #   ${pkgs.coreutils}/bin/sleep 5
  # '';

  # *** NOUVEAU Driver ***
  services.xserver = {
    videoDrivers = [ "modesetting" ];
    xrandrHeads = [
      { output = "DP-3"; primary = true; }
      {
        output = "DP-4";
        # monitorConfig = ''Option "Rotate" "left"'';
      }
    ];
  };

  services.xserver = {
    # set DPI
    dpi = 150;
    displayManager = {
      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
          Xft.dpi: 150
        EOF
      '';

      # turn on numlock in X11 by default
      lightdm.extraSeatDefaults =
        "greeter-setup-script=${pkgs.numlockx}/bin/numlockx on";
    };
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser ];

  hardware.firmware = [ pkgs.broadcom-bt-firmware ]; # for the plugable USB stick

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
      win = {
        path = "/mnt/win";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    samba
    home-manager
    efibootmgr
    efitools
    tpm2-tools
  ];

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

    oci-containers = {
      backend = "docker";

      containers.photoprism = {
        image = "photoprism/photoprism";
        environment = {
          PHOTOPRISM_ADMIN_PASSWORD = "changeme";
        };
        ports = [
          "2342:2342"
        ];
        autoStart = false;
      };
    };
  };

  ptsd.pulseaudio.virtualAudioMixin = {
    enable = true;
    microphone = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo";
    speakers = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";
    aecArgs = "beamforming=1 mic_geometry=-0.04,0,0,0.04,0,0 noise_suppression=1 analog_gain_control=0 digital_gain_control=1 agc_start_volume=200";
  };

  hardware.pulseaudio = {
    daemon.config = {
      # fix choppy audio when starting pavucontrol
      # required for UR44C, 48000 seems to cause choppy audio
      default-sample-rate = lib.mkForce 44100;
    };

    # LG sink-volume of 13107 =~ 20%
    extraConfig =
      let
        speakers = "alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo";
        headphone = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";
      in
      ''
        set-sink-volume ${speakers} 13107
        set-sink-mute ${speakers} 0
        set-sink-mute ${headphone} 0        
      '';
  };

  # services.nginx = {
  #   enable = true;

  #   package = pkgs.nginx.override {
  #     modules = with pkgs.nginxModules; [ fancyindex ];
  #   };

  #   commonHttpConfig = ''
  #     charset UTF-8;
  #     types_hash_max_size 4096;
  #     server_names_hash_bucket_size 128;
  #   '';

  #   virtualHosts = {

  #     "192.168.178.116" = {
  #       listen = [
  #         {
  #           addr = "192.168.178.116";
  #           port = 80;
  #         }
  #       ];
  #       locations."/" = {
  #         alias = "/home/enno/Downloads/";
  #         extraConfig = ''
  #           fancyindex on;
  #           fancyindex_exact_size off;
  #         '';
  #       };
  #     };
  #   };
  # };

  # networking.firewall.allowedTCPPorts = [ 80 ];

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/FPV" = {
        label = "FPV";
        id = "xxdwi-yom6n";
        devices = [ "nas1" "tp1" ];
      };
      "/home/enno/iOS" = {
        label = "iOS";
        id = "qm9ln-btyqu";
        devices = [ "nas1" "iph3" "tp1" "ws2" ];
      };
      "/home/enno/LuNo" = {
        label = "LuNo";
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1" "nuc1" "tp1" "tp2" ];
      };
      "/home/enno/Pocket" = {
        label = "Pocket";
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1" "tp1-win10" "ws1-win10" "ws2" ];
      };
      "/home/enno/Scans" = {
        label = "Scans";
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "tp1" "ws2" "iph3" ];
      };
      "/home/enno/Scans-Luisa" = {
        label = "Scans-Luisa";
        id = "dnryo-kz7io";
        devices = [ "nas1" ];
      };
      "/home/enno/Templates" = {
        label = "Templates";
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "tp1" "ws2" ];
      };
      "/home/enno/repos" = {
        label = "repos";
        id = "jihdi-qxmi3";
        devices = [ "nas1" "tp1" ];
        type = "sendonly";
      };
      "/mnt/photos/photos" = {
        label = "photos";
        id = "rqvar-xdhbm";
        devices = [ "nas1" ];
      };
      "/mnt/photos/photoprism-cache" = {
        label = "photoprism-cache";
        id = "tsfyr-53d26";
        devices = [ "nas1" ];
      };
    };
  };


}
