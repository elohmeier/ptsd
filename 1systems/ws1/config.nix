{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix

    ../../2configs/profiles/bs53.nix
    ../../2configs/profiles/workstation
    ../../2configs/prometheus/node.nix

    ../../2configs/nixbuild.nix

    ./modules/desktop.nix
    ./modules/networking.nix
    ./modules/syncthing.nix
    #  ./modules/netboot-host.nix
  ];

  # ptsd.motion = {
  #   enable = true;
  #   videoDevice = "/dev/video2";
  # };

  #ptsd.kanboard = {
  #  enable = true;
  #  domain = "localhost";
  #};

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

  ptsd.nwbackup = {
    enable = true;
    repos.nas1 = "borg-${config.networking.hostName}@192.168.178.12:.";
    paths = [
      "/home"
    ];
  };

  # default: poweroff
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    RuntimeDirectorySize=80%
  '';

  environment.systemPackages = with pkgs;
    let
      usbdevxml = vendorId: productId: writeText "usbdev-${vendorId}-${productId}.xml" ''
        <hostdev mode='subsystem' type='usb' managed='yes'>
          <source>
            <vendor id='0x${vendorId}'/>
            <product id='0x${productId}'/>
          </source>
        </hostdev>
      '';
      vminputChange = cmd: writeShellScriptBin "win10_3d-${cmd}" ''
        echo "Microsoft Ergonimic Keyboard: ${cmd}"
        sudo virsh ${cmd} win10_3d ${usbdevxml "045e" "082c"}
        echo "Logitech USB Receiver: ${cmd}"
        sudo virsh ${cmd} win10_3d ${usbdevxml "046d" "c52b"}
      '';
    in
    [
      #run-kali-vm
      #run-win-vm
      efibootmgr
      efitools
      tpm2-tools
      (vminputChange "attach-device")
      (vminputChange "detach-device")
      art
    ];

  specialisation = {
    nvidia-headless.configuration = {
      ptsd.nvidia.headless.enable = true;
      ptsd.nvidia.vfio.enable = false;
    };
  };
}
