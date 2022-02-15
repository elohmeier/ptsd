{ config, lib, pkgs, ... }:

{
  # WIP (needs more testing)
  # environment.etc."libinput/touchpad.quirks".text = lib.generators.toINI { } {
  #   "Touchpad pressure override" = {
  #     MatchUdevType = "touchpad";
  #     MatchName = "Synaptics TM3381-002";
  #     MatchDMIModalias = "dmi:*svnLENOVO:*:pvrThinkPadX280*";
  #     AttrPressureRange = "80:30";
  #   };
  # };

  services.tlp.enable = true; # TLP Linux Advanced Power Management
  services.fwupd.enable = true;

  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "hid_microsoft" ];
  boot.kernelModules = [ "kvm-intel" "dm-snapshot" ]; # tp_smapi is not yet compatible
  boot.kernelParams = [
    "zfs.zfs_arc_max=6442451000" # max ARC size: 6GB (instead of default 8GB)
    "mitigations=off" # make linux fast again

    # enable updated GPU firmware loading
    # https://wiki.archlinux.org/index.php/Intel_graphics#Enable_GuC_/_HuC_firmware_loading
    "i915.enable_guc=2"

    # try fix post-resume freeze - not working
    # "i8042.direct"
    # "i8042.dumpkbd"
  ];


  # workaround random wifi drops
  # see https://bugzilla.kernel.org/show_bug.cgi?id=203709
  boot.kernelPatches = [
    {
      name = "beacon_timeout.patch";
      patch = pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/mikezackles/linux-beacon-pkgbuild/8b6f0781a063405df78d6e31eabb12e60c51c814/beacon_timeout.patch";
        sha256 = "sha256-xBOvDaCqoK8Xa89ml4F14l6uokWMWsvdPnNg5HYMMag=";
      };
    }
  ];

  hardware.firmware = with pkgs; [ wireless-regdb firmwareLinuxNonfree ];
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="DE"
    options iwlwifi beacon_timeout=256
  '';

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # sample to pass USB access to VM
  # see https://github.com/NixOS/nixpkgs/issues/27199
  # SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="90cc", GROUP="users", MODE="0777"

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # intel-compute-runtime replaces intel-ocl for newer GPU generations
  # see https://github.com/intel/compute-runtime#supported-platforms
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      libvdpau-va-gl
      vaapiIntel
      vaapiVdpau
      intel-media-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      # intel-compute-runtime  # not available for i686
      libvdpau-va-gl
      vaapiIntel
      vaapiVdpau
    ];
  };

  services.acpid = {
    enable = true;
    #logEvents = true;
    handlers = {
      ibm-hotkey = {
        action = ''
          bl="/sys/class/leds/tpacpi::kbd_backlight/brightness"

          if [ "$1" = "ibm/hotkey LEN0268:00 00000080 00001315" ]; then
                  current=$(cat $bl)
                  case $current in
                          0)
                                  echo 1 > $bl
                                  ;;
                          1)
                                  echo 2 > $bl
                                  ;;
                          2)
                                  echo 0 > $bl
                                  ;;
                  esac
          fi
        '';
        event = "ibm/hotkey";
      };
    };
  };

  console.keyMap = "de-latin1";

  # set DPI
  # https://wiki.archlinux.org/index.php/HiDPI
  services.xserver = {
    xrandrHeads = [
      {
        output = "eDP-1";
        primary = true;
        monitorConfig = "DisplaySize 277 156"; # in millimeters
      }
    ];

    # 176 is physical DPI, next two settings are only necessary if using DPI != 176
    # since default 176 is calculated by above xrandrHeads configuration
    dpi = 120; # 1.25x scale
    displayManager.sessionCommands = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
        Xft.dpi: 120
      EOF
    '';
  };
  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1"; # honor screen DPI
  };
}
