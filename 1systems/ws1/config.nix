{ config, lib, pkgs, ... }:
with lib;
let
  universe = import ../../2configs/universe.nix;
in
{
  imports = [
    ../..
    ../../2configs
    #../../2configs/awscli.nix
    ../../2configs/cli-tools.nix
    ../../2configs/desktop.nix
    #../../2configs/gcalcli.nix
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix

    ../../2configs/themes/fraam.nix
    ../../2configs/mfc7440n.nix
    ../../2configs/prometheus/node.nix

    # <secrets-shared/nwsecrets.nix>
    # ../../2configs/home-secrets.nix

    ./qemu.nix
  ];
  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
  boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
  '';

  systemd.services.wol-eth0 = {
    description = "Wake-on-LAN for enp39s0";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp39s0 wol g"; # magicpacket
    };
  };


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
    mode = "sway";
    terminalConfig = "alacritty";
    waybar.enable = true;
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
  };

  ptsd.octoprint =
    {
      enable = false;
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

    bridges.br0.interfaces = [ "enp39s0" ];
    interfaces.br0.useDHCP = true;

    # hosts."10.129.127.250" = [ "s3.bucket.htb" "bucket.htb" ];
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

  # services.resolved = {
  #   enable = true;
  #   dnssec = "false";
  #   extraConfig = ''
  #     [Resolve]
  #     DNS=127.0.0.1:5053
  #     Domains=~htb
  #   '';
  # };

  # IP is reserved in DHCP server for us.
  # not using DHCP here, because we might receive a different address than post-initrd.
  boot.kernelParams = [
    "ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:enp39s0:off"
    "mitigations=off" # make linux fast again
  ];

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
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    RuntimeDirectorySize=80%
  '';

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
  #boot.kernelPackages = pkgs.linuxPackages_5_8; # required as of 20.09 (linux 5.8 instead of 5.4)
  boot.kernelPackages = pkgs.linuxPackages_latest; # for nixos-unstable
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
        devices = [ "nas1-st-enno" "tp1" ];
      };
      "/home/enno/LuNo" = {
        id = "3ull9-9deg4";
        devices = [ "mb1" "nas1-st-enno" "nas1-st-luisa" "nuc1" "tp1" "tp2" ];
      };
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "nas1-st-enno" "nuc1" "tp1" "tp1-win10" "ws1-win10" "ws2" ];
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
        devices = [ "nas1-st-enno" "tp1" "ws2" ];
      };
      "/home/enno/repos" = {
        id = "jihdi-qxmi3";
        devices = [ "nas1-st-enno" "tp1" ];
        type = "sendonly";
        label = "repos-ws1";
      };
    };
  };
}
