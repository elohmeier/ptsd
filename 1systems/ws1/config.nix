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

    ../../2configs/themes/fraam.nix
    ../../2configs/mfc7440n.nix
    ../../2configs/prometheus/node.nix

    # 
    # ../../2configs/home-secrets.nix

  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.blacklistedKernelModules = [
    # "nvidia"
    # "nvidia_drm"
    # "nvidia_uvm"
    # "nvidia_modeset"
    # "i2c_nvidia_gpu"
    "nouveau"
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
    fish.enable = true;
    defaultShell = "fish";
  };

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    darkmode = true;
    terminalConfig = "alacritty";
    waybar.enable = true;
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

    firewall.interfaces."${virshNatIf}" = {
      allowedTCPPorts = [ 53 631 445 139 ];
      allowedUDPPorts = [ 53 67 68 546 547 137 138 ];
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

  networking.firewall.interfaces.virbr4 = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

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
        id = "xxdwi-yom6n";
        devices = [ "nas1" "tp1" ];
      };
      "/home/enno/LuNo" = {
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1" "nuc1" "tp1" "tp2" ];
      };
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1" "tp1-win10" "ws1-win10" "ws2" ];
      };
      "/home/enno/Scans" = {
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "tp1" ];
      };
      "/home/enno/Scans-Luisa" = {
        id = "dnryo-kz7io";
        devices = [ "nas1" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "tp1" "ws2" ];
      };
      "/home/enno/repos" = {
        id = "jihdi-qxmi3";
        devices = [ "nas1" "tp1" ];
        type = "sendonly";
        label = "repos-ws1";
      };
    };
  };


}
