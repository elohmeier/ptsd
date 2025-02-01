{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./modules/disko.nix
  ];

  networking.hostName = "tp3";
  networking.hostId = "c1acffeb";

  system.stateVersion = "24.11";

  ptsd.tailscale.enable = true;

  programs.fish.enable = true;

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

    loader = {
      systemd-boot.enable = true;
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
    # kernelPackages = pkgs.linuxPackages_latest;
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
  services.getty.autologinUser = "root";

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

  sops = {
    defaultSopsFile = ../../../secrets/tp3.yaml;
    secrets."mainuser.passwd".neededForUsers = true;
    secrets."root.passwd".neededForUsers = true;
  };

  users.users.mainUser.hashedPasswordFile = config.sops.secrets."mainuser.passwd".path;
  users.users.root.hashedPasswordFile = config.sops.secrets."root.passwd".path;

  services.zfs = {
    autoSnapshot.enable = true;
    autoSnapshot.monthly = lib.mkDefault 1;
    autoScrub.enable = true;
  };
}
