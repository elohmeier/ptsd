{ config, lib, pkgs, ... }:
with lib;
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
    ../../2configs/profiles/bs53.nix
    ../../2configs/profiles/workstation
    ../../2configs/prometheus/node.nix

    ./modules/syncthing.nix
    #  ./modules/netboot-host.nix
  ];

  programs.ssh.knownHosts."18.193.115.167".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYuIUn5f2MGpd2+nTkLBdQ4zTC/3TMvUpf6D1+dtE+F";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  #   nix = {
  #     distributedBuilds = true;
  #     buildMachines = [
  #       {
  #         hostName = "18.193.115.167";
  #         maxJobs = 64;
  #         sshKey = "/home/enno/repos/ptsd/awsbuilder.id_ed25519";
  #         sshUser = "root";
  #         system = "aarch64-linux";
  #         supportedFeatures = [ "big-parallel" ];
  #       }
  #     ];
  #   };

  ptsd.photoprism = {
    enable = true;
    #httpHost = "127.0.0.1";
    #httpPort = 2342;
    #siteUrl = "http://127.0.0.1/";
    httpHost = "192.168.178.67";
    httpPort = 8080;
    siteUrl = "http://192.168.178.67:8080/";
    cacheDirectory = "/mnt/photos/photoprism-cache";
    dataDirectory = "/mnt/photos/photoprism-lib";
    photosDirectory = "/mnt/photos/photos";
    user = "enno";
    group = "users";
    autostart = false;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ptsd.nwacme.hostCert.enable = false;

  ptsd.desktop = {
    enable = true;
    waybar.co2 = true;
    # nvidia.enable = true; # todo: replace writeNu in desktop module
    autolock.enable = false;
    baresip = {
      enable = true;
      audioPlayer = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";
      audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.pro-input-0";
      audioAlert = "alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo";
    };
    fontSize = 18.0;
    waybar.primaryOutput = "Dell Inc. DELL P2415Q D8VXF96K09HB";
  };

  home-manager.users.mainUser = { pkgs, ... }: {
    wayland.windowManager.sway.config.output = {
      "Goldstar Company Ltd LG UltraFine 701NTAB7S144" = {
        pos = "0 0";
        mode = "4096x2304@59.999Hz";
        scale = "1";
      };
      "Dell Inc. DELL P2415Q D8VXF96K09HB" = {
        #pos = "0 2304";
        pos = "256 2304";
        mode = "3840x2160@59.997Hz";
        scale = "1";
      };
      "Dell Inc. DELL P2415Q D8VXF64G0LGL" = {
        # pos = "3840 2304";
        pos = "4096 360";
        mode = "3840x2160@59.997Hz";
        scale = "1";
        transform = "270";
      };
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
      eth0 = {
        allowedTCPPorts = [ 3389 ]; # for optional rdp forwarding
      };
    };

    nat.externalInterface = "eth0";
  };

  ptsd.secrets.files."Bundesdatenschutzzentrale 5GHz.psk" = {
    path = "/var/lib/iwd/Bundesdatenschutzzentrale 5GHz.psk";
  };

  systemd.network = {
    networks = {
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
    #"ip=${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}::192.168.178.1:255.255.255.0:${config.networking.hostName}:enp39s0:off"
    "mitigations=off" # make linux fast again
    "amd_iommu=on"
    "video=vesafb:off"
    "video=efifb:off"
  ];

  # ptsd.wireguard.networks.fraam_buero_vpn = {
  #   enable = true;
  #   ip = universe.hosts."${config.networking.hostName}".nets.fraam_buero_vpn.ip4.addr;
  #   keyname = "nwvpn.key";
  # };

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

  services.samba.shares.win = {
    path = "/mnt/win";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
  };

  environment.systemPackages = with pkgs; [
    efibootmgr
    efitools
    tpm2-tools
  ];

  specialisation = {
    nvidia-headless.configuration = {
      ptsd.nvidia.headless.enable = true;
      ptsd.nvidia.vfio.enable = false;
    };
  };
}
