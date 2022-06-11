{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix

    ../../2configs/virtualisation.nix
    ../../2configs/workstation.nix
    ../../2configs/prometheus/node.nix
    ../../2configs/printers/mfc7440n.nix

    ../../2configs/nixbuild.nix

    ./modules/desktop.nix
    ./modules/networking.nix
    ./modules/syncthing.nix
    ./modules/vmassi.nix
  ];

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

  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ptsd.nwacme.hostCert.enable = false;

  ptsd.nwbackup = {
    enable = true;
    paths = [
      "/home"
    ];
  };

  # default: poweroff
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    RuntimeDirectorySize=80%
  '';

  environment.systemPackages = with pkgs; [
    #run-kali-vm
    #run-win-vm
    efibootmgr
    efitools
    tpm2-tools
    art
  ];

  # specialisation = {
  #   nvidia-headless.configuration = {
  #     ptsd.nvidia.headless.enable = true;
  #     ptsd.nvidia.vfio.enable = false;
  #   };
  # };
}
