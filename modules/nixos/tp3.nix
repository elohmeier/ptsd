({ config, lib, pkgs, ... }: {

  imports = [
    ./nix-security-box/cloud.nix
    ./nix-security-box/container.nix
    ./nix-security-box/dns.nix
    ./nix-security-box/exploits.nix
    ./nix-security-box/fuzzers.nix
    ./nix-security-box/generic.nix
    ./nix-security-box/information-gathering.nix
    ./nix-security-box/kubernetes.nix
    ./nix-security-box/ldap.nix
    ./nix-security-box/load-testing.nix
    ./nix-security-box/malware.nix
    ./nix-security-box/network.nix
    ./nix-security-box/password.nix
    ./nix-security-box/port-scanners.nix
    ./nix-security-box/proxies.nix
    ./nix-security-box/services.nix
    ./nix-security-box/tls.nix
    ./nix-security-box/traffic.nix
    ./nix-security-box/tunneling.nix
    ./nix-security-box/web.nix
    ./nix-security-box/windows.nix
    ./nix-security-box/wireless.nix
  ];
  #config.permittedInsecurePackages = [
  #  "tightvnc-1.3.10"
  #  "python-2.7.18.6"
  #];

  system.stateVersion = "23.11";
  networking.hostName = "tp3";
  # services.getty.autologinUser = config.users.users.mainUser.name;
  ptsd.tailscale.enable = true;
  disko.devices = import ./disko/luks-lvm-immutable.nix {
    inherit lib;
  };
  programs.fish.enable = true;
  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [ "size=1G" "mode=1755" ];
    };
  };
  swapDevices = [
    { device = "/dev/pool/swap"; }
  ];
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

    lanzaboote = {
      enable = true;
      pkiBundle = "/nix/persistent/etc/secureboot";
    };

    loader = {
      systemd-boot.enable = lib.mkForce false; # replaced by lanzaboote
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

      kernelModules = [
        "amdgpu"
      ];

      systemd = {
        enable = true;
        emergencyAccess = true;
        network.wait-online.timeout = 0;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" "acpi_call" ];
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  };
  systemd.network.wait-online.timeout = 0;
  services.fstrim.enable = true;
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
    displayManager.lightdm = {
      background = "#008080";
      greeters.gtk = {
        cursorTheme = {
          package = pkgs.chicago95;
          name = "Chicago95 Animated Hourglass Cursors";
        };
        iconTheme = {
          package = pkgs.chicago95;
          name = "Chicago95";
        };
        theme = {
          package = pkgs.chicago95;
          name = "Chicago95";
        };
      };
    };
    videoDrivers = [ "modesetting" ];
    libinput.enable = true;
    libinput.touchpad.naturalScrolling = true;
    libinput.mouse.naturalScrolling = true;
    xkbOptions = "eurosign:e,terminate:ctrl_alt_bksp,compose:ralt";
  };
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.xfce.thunar-archive-plugin ];
  };
  programs.steam.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  boot.plymouth = {
    enable = true;
    logo = ../src/Microsoft_Windows_95_wordmark.png;
  };
  specialisation.plymouth95.configuration = {
    boot.plymouth = {
      enable = true;
      theme = "Chicago95";
      themePackages = [ pkgs.chicago95 ];
    };
  };

  services.xbanish.enable = true;

  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
  powerManagement.cpuFreqGovernor = "schedutil";
  powerManagement.powertop.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  environment.systemPackages = [
    pkgs.alsa-utils
    pkgs.btop
    pkgs.chicago95
    pkgs.file
    pkgs.git
    pkgs.glxinfo
    pkgs.gnome.gnome-disk-utility
    pkgs.home-manager
    pkgs.libcanberra-gtk3
    pkgs.libinput
    pkgs.pavucontrol
    pkgs.powertop
    pkgs.python3 # required by proton (steam)
    pkgs.sbctl
    pkgs.vulkan-tools
    pkgs.xclip
    pkgs.xfce.xfce4-pulseaudio-plugin
    pkgs.xfce.xfce4-fsguard-plugin
    pkgs.xsel
  ];
  fonts.packages = [ pkgs.chicago95 ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ]; # manual start to reduce battery usage (frequent wakeups)

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };
})

