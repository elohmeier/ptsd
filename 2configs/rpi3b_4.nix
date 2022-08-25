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

  # reduce size
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  hardware.enableRedistributableFirmware = lib.mkDefault false;
  hardware.firmware = [ firmware-brcm pkgs.raspberrypiWirelessFirmware ];
  hardware.wirelessRegulatoryDatabase = true;
  services.udisks2.enable = false;

  console.keyMap = "de-latin1";

  boot = {
    initrd = {
      includeDefaultModules = false;
      systemd = {
        enable = true;
        emergencyAccess = true;
      };
    };
    #kernelPackages = pkgs.linuxPackages_rpi3;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    tmpOnTmpfs = true;
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    wireless.enable = false;
    wireless.iwd.enable = true;
  };

  services.resolved = { enable = true; dnssec = "false"; };

  ptsd.secrets.enable = false;

  systemd.network.wait-online.timeout = 0;

  systemd.network.networks = {
    eth = {
      matchConfig.Driver = "smsc95xx bcmgenet"; # rpi3 / rpi4
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        ConfigureWithoutCarrier = true;
        DHCP = "yes";
      };
      dhcpV4Config.RouteMetric = 10;
      ipv6AcceptRAConfig.RouteMetric = 10;
    };
    wlan = {
      matchConfig.Driver = "brcmfmac";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 20;
      ipv6AcceptRAConfig.RouteMetric = 20;
    };
  };

  services.journald.extraConfig = "Storage=volatile";

  services.openssh.hostKeys = [
    { type = "rsa"; bits = 4096; path = "/nix/persistent/etc/ssh/ssh_host_rsa_key"; }
    { type = "ed25519"; path = "/nix/persistent/etc/ssh/ssh_host_ed25519_key"; }
  ];

  system.activationScripts.initialize-persistent = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /nix/persistent/etc/ssh
    mkdir -p /nix/persistent/var/lib/iwd
    ${pkgs.systemd}/bin/systemd-machine-id-setup --root /nix/persistent
  '';

  fileSystems = {
    "/var/lib/iwd" = {
      device = "/nix/persistent/var/lib/iwd";
      options = [ "bind" ];
    };
    "/etc/machine-id" = {
      device = "/nix/persistent/etc/machine-id";
      options = [ "bind" ];
    };
  };

  imports = [
    ./sd-image.nix
  ];

  sdImage = {
    populateFirmwareCommands =
      let
        configTxt = pkgs.writeText "config.txt" ''
          [pi3]
          kernel=u-boot-rpi3.bin

          [pi4]
          kernel=u-boot-rpi4.bin
          enable_gic=1
          armstub=armstub8-gic.bin

          # Otherwise the resolution will be weird in most cases, compared to
          # what the pi3 firmware does by default.
          disable_overscan=1

          # Supported in newer board revisions
          arm_boost=1

          [all]
          # Boot in 64-bit mode.
          arm_64bit=1

          # U-Boot needs this to work, regardless of whether UART is actually used or not.
          # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
          # a requirement in the future.
          enable_uart=1
      
          # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
          # when attempting to show low-voltage or overtemperature warnings.
          avoid_warnings=1
        '';
      in
      ''
        fw=${pkgs.raspberrypifw}/share/raspberrypi/boot
        ${pkgs.rsync}/bin/rsync -av \
          $fw/bootcode.bin \
          $fw/fixup*.dat \
          $fw/start*.elf \
          "$NIX_BUILD_TOP/firmware/"

        # Add pi3 specific files
        ${pkgs.rsync}/bin/rsync -av ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin "$NIX_BUILD_TOP/firmware/u-boot-rpi3.bin"

        # Add pi4 specific files
        ${pkgs.rsync}/bin/rsync -av ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin "$NIX_BUILD_TOP/firmware/u-boot-rpi4.bin"
        ${pkgs.rsync}/bin/rsync -av ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin "$NIX_BUILD_TOP/firmware/armstub8-gic.bin"
        ${pkgs.rsync}/bin/rsync -av ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb "$NIX_BUILD_TOP/firmware/bcm2711-rpi-4-b.dtb"

        cp -v ${configTxt} "$NIX_BUILD_TOP/firmware/config.txt"
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
