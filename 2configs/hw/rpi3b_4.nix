# for rpi4: include nixos-hardware.nixosModules.raspberry-pi-4 in nixosSystem.modules in flake.nix (not required for rpi3b)

{ config, lib, pkgs, ... }:

let
  # just take the needed firmware files to reduce size
  firmware-brcm = pkgs.runCommand "firmware-brcm" { } ''          
    mkdir -p $out/lib/firmware
    ${pkgs.rsync}/bin/rsync -av ${pkgs.firmwareLinuxNonfree}/lib/firmware/{brcm,cypress} $out/lib/firmware/
  '';
in
{
  zramSwap = {
    enable = true;
    numDevices = 1;
    swapDevices = 1;
    memoryPercent = 75;
    algorithm = "zstd";
  };

  hardware.enableRedistributableFirmware = lib.mkDefault false; # override nixos-hardware default
  hardware.firmware = [ firmware-brcm pkgs.raspberrypiWirelessFirmware ];
  hardware.wirelessRegulatoryDatabase = true;

  console.keyMap = "de-latin1";

  networking = {
    useDHCP = false;
    useNetworkd = true;
    wireless.enable = false;
    wireless.iwd.enable = lib.mkDefault true;
  };

  services.resolved = { enable = true; dnssec = "false"; };

  systemd.network.wait-online.timeout = 0;

  systemd.network.networks = {
    eth = {
      matchConfig.Driver = "smsc95xx bcmgenet"; # rpi3 / rpi4
      linkConfig.RequiredForOnline = if config.networking.wireless.iwd.enable then "no" else "yes";
      networkConfig = {
        ConfigureWithoutCarrier = true;
        DHCP = "yes";
      };
      dhcpV4Config.RouteMetric = 10;
      ipv6AcceptRAConfig.RouteMetric = 10;
    };
  } // lib.optionalAttrs (config.networking.wireless.iwd.enable) {
    wlan = {
      dhcpV4Config.RouteMetric = 20;
      ipv6AcceptRAConfig.RouteMetric = 20;
      matchConfig.Driver = "brcmfmac";
      networkConfig.DHCP = "yes";
    };
  };

  environment.systemPackages = with pkgs;[ libraspberrypi usbutils ];

  # device access required for vcgencmd
  services.udev.extraRules = ''
    KERNEL=="vchiq",GROUP="video",MODE="0660"
  '';
}
