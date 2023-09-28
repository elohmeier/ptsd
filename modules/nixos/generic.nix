{ config, lib, pkgs, ... }:

with lib;
let
  inherit (config.boot.kernelPackages) nvidia_x11;
  inherit (config.nixpkgs.hostPlatform) isx86_64;
  cfg = config.ptsd.generic;
in
{
  imports = [
    ./users/root.nix
  ];

  options.ptsd.generic = {
    amdgpu.enable = mkOption {
      type = types.bool;
      default = isx86_64;
      description = "Enable amdgpu support";
    };
    nvidia.enable = mkOption {
      type = types.bool;
      default = isx86_64;
      description = "Enable nvidia support";
    };
    nvidia.cuda.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable cuda support";
    };
  };

  config = {

    boot = {
      blacklistedKernelModules = optional isx86_64 "nouveau";

      extraModulePackages = optional cfg.nvidia.enable nvidia_x11.bin;

      initrd = {
        availableKernelModules = [
          "9p"
          "9pnet_virtio"
          "ahci"
          "ata_piix"
          "ehci_pci"
          "hid_microsoft"
          "ntfs3"
          "nvme"
          "ohci_pci"
          "sd_mod"
          "sr_mod"
          "uhci_hcd"
          "usb_storage"
          "usbhid"
          "virtio_blk"
          "virtio_mmio"
          "virtio_net"
          "virtio_pci"
          "virtio_scsi"
          "xhci_pci"
        ];

        kernelModules = [
          "virtio_balloon"
          "virtio_console"
          "virtio_rng"
        ] ++ optional cfg.amdgpu.enable "amdgpu";

        systemd = {
          enable = mkDefault true;
          emergencyAccess = true;
        };
      };

      kernelPackages = mkDefault pkgs.linuxPackages_latest;

      kernelModules = optionals isx86_64 [
        "kvm-amd"
        "kvm-intel"
        "tcp_bbr"
      ] ++ optional cfg.nvidia.cuda.enable "nvidia-uvm";

      tmpOnTmpfs = true;

      # speed up networking, affects both IPv4 and IPv6r
      kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
    };

    powerManagement.cpuFreqGovernor = mkDefault "schedutil";

    hardware.cpu.amd.updateMicrocode = isx86_64;
    hardware.cpu.intel.updateMicrocode = isx86_64;
    hardware.enableAllFirmware = true;

    hardware.firmware = with pkgs; [
      firmwareLinuxNonfree
      broadcom-bt-firmware # for the plugable USB stick
    ];

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = isx86_64;
      extraPackages = with pkgs; optionals cfg.amdgpu.enable [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      extraPackages32 = with pkgs; optional cfg.amdgpu.enable driversi686Linux.amdvlk;
    };

    console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";

    services.xserver = {
      videoDrivers = optional cfg.amdgpu.enable "amdgpu" ++ optional cfg.nvidia.enable "nvidia";
    };

    environment.systemPackages = with pkgs; [
      btop
      cifs-utils
      cryptsetup
      git
      gptfdisk
      hashPassword
      home-manager
      neovim
      nnn
      pciutils
      smartmontools
      tmux
      usbutils
    ] ++ optionals cfg.nvidia.cuda.enable [
      cudatoolkit
      nvtop
    ];

    networking = {
      useDHCP = false;
      useNetworkd = true;
    };

    systemd.network.networks = {
      eth = mkIf (!config.networking.networkmanager.enable) {
        dhcpV4Config.RouteMetric = 10;
        ipv6AcceptRAConfig.RouteMetric = 10;
        linkConfig.RequiredForOnline = mkIf config.networking.wireless.iwd.enable "no";
        matchConfig.Type = "ether";
        networkConfig = { ConfigureWithoutCarrier = true; DHCP = "yes"; };
      };
      wlan = mkIf (config.networking.wireless.iwd.enable && !config.networking.networkmanager.enable) {
        dhcpV4Config.RouteMetric = 20;
        ipv6AcceptRAConfig.RouteMetric = 20;
        matchConfig.Type = "wlan";
        networkConfig.DHCP = "yes";
      };
    };

    services.resolved = {
      enable = true;
      # dnssec = "false";
    };

    # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
    boot.kernel.sysctl."fs.inotify.max_user_watches" = mkIf config.services.syncthing.enable 204800;

    ptsd.secrets.enable = false;
    ptsd.tailscale.enable = true;

    services.udisks2.enable = lib.mkDefault false;
    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "root" "@wheel" ];

    services.eternal-terminal.enable = true;
    networking.firewall.allowedTCPPorts = [ 2022 ];
  };
}
