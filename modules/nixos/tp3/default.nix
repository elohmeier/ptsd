(
  {
    config,
    lib,
    pkgs,
    ...
  }:
  {

    imports = [
      # ./nix-security-box/cloud.nix
      # ./nix-security-box/container.nix
      # ./nix-security-box/dns.nix
      # ./nix-security-box/exploits.nix
      # ./nix-security-box/fuzzers.nix
      # ./nix-security-box/generic.nix
      # ./nix-security-box/information-gathering.nix
      # ./nix-security-box/kubernetes.nix
      # ./nix-security-box/ldap.nix
      # ./nix-security-box/load-testing.nix
      # ./nix-security-box/malware.nix
      # ./nix-security-box/network.nix
      # ./nix-security-box/password.nix
      # ./nix-security-box/port-scanners.nix
      # ./nix-security-box/proxies.nix
      # ./nix-security-box/services.nix
      # ./nix-security-box/tls.nix
      # ./nix-security-box/traffic.nix
      # ./nix-security-box/tunneling.nix
      # ./nix-security-box/web.nix
      # ./nix-security-box/windows.nix
      # ./nix-security-box/wireless.nix

      ./modules/disko.nix
    ];

    networking.hostId = "c1acffeb";

    #config.permittedInsecurePackages = [
    #  "tightvnc-1.3.10"
    #  "python-2.7.18.6"
    #];

    system.stateVersion = "24.11";
    networking.hostName = "tp3";
    # services.getty.autologinUser = config.users.users.mainUser.name;
    ptsd.tailscale.enable = true;
    # disko.devices = import ./disko/luks-lvm-immutable.nix { inherit lib; };
    programs.fish.enable = true;
    # fileSystems = {
    #   "/" = {
    #     fsType = "tmpfs";
    #     options = [
    #       "size=4G"
    #       "mode=1755"
    #     ];
    #   };
    # };
    # swapDevices = [ { device = "/dev/pool/swap"; } ];
    time.timeZone = "Europe/Berlin";
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    services.fwupd.enable = true;
    boot = {
      kernelParams = [
        "mitigations=off" # make linux fast again
        "acpi_backlight=native" # force thinkpad_acpi driver
        "amd_pstate=active"
      ];

      resumeDevice = "/dev/pool/swap";

      # lanzaboote = {
      #   enable = true;
      #   pkiBundle = "/nix/persistent/etc/secureboot";
      #   configurationLimit = 7;
      # };

      loader = {
        systemd-boot.enable = true;
        # systemd-boot.enable = lib.mkForce false; # replaced by lanzaboote
        systemd-boot.editor = false;
        efi.canTouchEfiVariables = true;
      };
      initrd = {
        availableKernelModules = [
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
          "xhci_pci"
        ];

        kernelModules = [ "amdgpu" ];

        systemd = {
          enable = true;
          emergencyAccess = true;
          network.wait-online.timeout = 0;
        };
      };
      kernelPackages = pkgs.linuxPackages_latest;
      kernelModules = [
        "kvm-amd"
        "acpi_call"
      ];
      extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    };
    systemd.network.wait-online.timeout = 0;
    services.fstrim.enable = true;
    services.xserver.videoDrivers = [ "modesetting" ];
    # programs.steam.enable = true;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    };

    services.xbanish.enable = true;

    nix.settings = {
      trusted-users = [ config.users.users.mainUser.name ];
    };

    console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
    powerManagement.cpuFreqGovernor = "schedutil";
    powerManagement.powertop.enable = true;
    hardware.cpu.amd.updateMicrocode = true;
    environment.systemPackages = [
      pkgs.alsa-utils
      pkgs.btop
      pkgs.file
      pkgs.git
      # pkgs.glxinfo
      # pkgs.gnome-disk-utility
      pkgs.gptfdisk
      pkgs.home-manager
      pkgs.libcanberra-gtk3
      pkgs.powertop
      pkgs.python3 # required by proton (steam)
      pkgs.sbctl
      pkgs.vulkan-tools
      pkgs.wirelesstools
    ];

    # virtualisation.podman.enable = true;
    # virtualisation.virtualbox.host.enable = true;

    systemd.services.tailscaled.wantedBy = lib.mkForce [ ]; # manual start to reduce battery usage (frequent wakeups)

    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    # syncthing
    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [
        21027
        22000
      ];
    };
  }
)
