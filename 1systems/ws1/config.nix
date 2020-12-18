with import <ptsd/lib>;
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
    <ptsd/2configs/drone-exec-container.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/nextcloud-client.nix>
    <ptsd/2configs/prometheus/node.nix>

    <secrets-shared/nwsecrets.nix>
    <client-secrets/dbk/vdi.nix>
    <ptsd/2configs/home-secrets.nix>

    <home-manager/nixos>
    <ptsd/2configs/xrdp.nix>

    ./qemu.nix
  ];

  ptsd.octoprint =
    {
      enable = true;
      plugins = plugins: [
        (plugins.callPackage <ptsd/5pkgs/octoprint-plugins/bedlevelvisualizer.nix> { })
        (plugins.callPackage <ptsd/5pkgs/octoprint-plugins/bltouch.nix> { })
        plugins.printtimegenius
      ];
    };

  # TODO: 20.09 compat
  # https://github.com/cleverca22/nixos-configs/issues/6
  #qemu-user.arm = true;
  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  ptsd.nwbackup.repos.nas1 = "borg-${config.networking.hostName}@192.168.178.12:.";

  services.avahi.enable = true;

  networking = {
    hostName = "ws1";
    useNetworkd = true;
    useDHCP = false;

    bridges.br0.interfaces = [ "enp39s0" ];
    interfaces.br0.useDHCP = true;
  };

  systemd.network.networks."40-br0".routes = [
    {
      routeConfig = {
        Destination = "${universe.hosts.nas1.nets.nwvpn.ip4.addr}/32";
        Gateway = universe.hosts.nas1.nets.bs53lan.ip4.addr;
        GatewayOnLink = "yes";
      };
    }
  ];

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [ "ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:enp39s0:off" ];

  ptsd.wireguard.networks = {
    dlrgvpn = {
      enable = true;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      client.allowedIPs = [ "192.168.168.0/24" ];
      routes = [
        { routeConfig = { Destination = "192.168.168.0/24"; }; }
      ];
      keyname = "nwvpn.key";
    };
  };

  # default: poweroff
  #services.logind.extraConfig = "HandlePowerKey=suspend";

  ptsd.vdi-container = {
    enable = true;
    extIf = "br0";
  };

  # *** NVIDIA Driver
  # boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
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
  boot.kernelPackages = pkgs.linuxPackages_5_8; # required as of 20.09 (linux 5.8 instead of 5.4)
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
      security = user
      hosts allow = 192.168.101.0/24 # host-only-virsh network
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
      qemuRunAsRoot = false; # TODO: test permissions
    };
  };

  hardware.pulseaudio = {
    daemon.config = {
      # fix choppy audio when starting pavucontrol
      # required for UR44C, 48000 seems to cause choppy audio
      default-sample-rate = lib.mkForce 44100;
    };

    # Virtual audio mixin into mic audio config
    # from https://wiki.archlinux.org/index.php/PulseAudio/Examples#Mixing_additional_audio_into_the_microphone's_audio
    # Symbology: (Application), {Audio source}, [Audio sink], {m} = Monitor of audio sink
    #
    # {Microphone}
    #    ||                                             Input
    # {mic_ec} -------------> [vsink_fx_mic]{m} ------------> (Voice chat)
    #             Loopback               ^                         |
    #                            Loopback|                   Output|
    #                                    |                         |
    #              Output                |      Loopback           v
    # (Soundboard) ---------> [vsink_fx]{m} ----------------> [spk_ec]
    #                                                            ||
    #                                                         [Speakers]

    # LG sink-volume of 13107 =~ 20%
    extraConfig =
      let
        speaker = "alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo";
        headphone = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";
        microphone = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo";
      in
      ''
        load-module module-echo-cancel use_master_format=1 source_master=${microphone} source_name=mic_ec source_properties=device.description=mic_ec sink_master=${headphone} sink_name=spk_ec sink_properties=device.description=spk_ec aec_method=webrtc aec_args="beamforming=1 mic_geometry=-0.04,0,0,0.04,0,0 noise_suppression=1 analog_gain_control=0 digital_gain_control=1 agc_start_volume=200"
        set-sink-volume ${speaker} 13107
        set-sink-mute ${speaker} 0
        set-sink-mute ${headphone} 0
        load-module module-null-sink sink_name=vsink_fx     sink_properties=device.description=vsink_fx
        load-module module-null-sink sink_name=vsink_fx_mic sink_properties=device.description=vsink_fx_mic
        load-module module-loopback latency_msec=30 adjust_time=3 source=mic_ec           sink=vsink_fx_mic
        load-module module-loopback latency_msec=30 adjust_time=3 source=vsink_fx.monitor sink=vsink_fx_mic
        load-module module-loopback latency_msec=30 adjust_time=3 source=vsink_fx.monitor sink=spk_ec
        set-default-source vsink_fx_mic.monitor
        set-default-sink   spk_ec
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

  # TODO: really needed?!
  # hardware.logitech.wireless = {
  #   enable = true;
  #   enableGraphical = true;
  # };

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/FPV" = {
        id = "xxdwi-yom6n";
        devices = [ "nas1-st-enno" "tp1" ];
      };
      "/home/enno/LuNo" = {
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1-st-enno" "nas1-st-luisa" "nuc1" "tp1" "tp2" ];
      };
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "htz2" "nas1-st-enno" "nuc1" "tp1" "tp1-win10" "ws1-win10" ];
      };
      "/home/enno/Scans" = {
        id = "ezjwj-xgnhe";
        devices = [ "nas1-st-enno" ];
      };
      "/home/enno/Scans-Luisa" = {
        id = "dnryo-kz7io";
        devices = [ "nas1-st-luisa" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1-st-enno" "tp1" ];
      };
      "/home/enno/repos" = {
        id = "jihdi-qxmi3";
        devices = [ "nas1-st-enno" "tp1" ];
        type = "sendonly";
        label = "repos-ws1";
      };
    };
  };

  hardware.pulseaudio.package = (
    pkgs.pulseaudioFull.overrideAttrs (
      old: {
        patches = [
          # mitigate https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/issues/89
          ../../2configs/patches/echo-cancel-make-webrtc-beamforming-parameter-parsing-locale-independent.patch
        ];
      }
    )
  );
}
