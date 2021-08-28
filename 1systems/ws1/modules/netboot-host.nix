{ config, lib, modulesPath, pkgs, nixpkgs, ... }:

let
  interface = "enp39s0";
  localIP = "172.16.77.1";

  bootSystem = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      (modulesPath + "/installer/netboot/netboot-minimal.nix")

      ({ pkgs, ... }: {
        system.build.firmware =
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

              # disable missing sdcard log spam
              dtparam=sd_poll_once=on
            '';
          in
          pkgs.runCommand "firmware" { } ''
            mkdir -p $out
            (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $out/)

            # Add the config
            cp ${configTxt} $out/config.txt

            # Add pi3 specific files
            cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin $out/u-boot-rpi3.bin

            # Add pi4 specific files
            cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin $out/u-boot-rpi4.bin
            cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/armstub8-gic.bin
            cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb $out/   
          '';
      })

    ];
  };

  # see https://github.com/ARM-software/u-boot/blob/master/doc/README.pxe
  pxelinuxMenu = pkgs.writeTextFile
    {
      name = "pxelinux-menu";
      text = ''
        menu title Linux selections

        label nixos
          kernel Image
          append init=${bootSystem.config.system.build.toplevel}/init ${toString bootSystem.config.boot.kernelParams}
          initrd initrd
      '';
      destination = "/pxelinux.cfg/menus/base.menu";
    };

  pxelinuxConfig = pkgs.writeTextFile {
    name = "pxelinux-config";
    text = ''
      menu include pxelinux.cfg/menus/base.menu
      timeout 10

      default nixos
    '';
    destination = "/pxelinux.cfg/default";
  };

  tftpRoot = with bootSystem.config.system.build; pkgs.symlinkJoin {
    name = "ipxeBootDir";
    paths = [
      netbootRamdisk
      kernel
      firmware
      pxelinuxConfig
      pxelinuxMenu
    ];
  };
in
{

  services.nginx = {
    enable = true;
    virtualHosts = {
      "${localIP}" = {
        listen = [{
          addr = localIP;
        }];
        locations."/" = {
          root = tftpRoot;
        };
      };
    };
  };

  services.atftpd = {
    enable = false;
    root = tftpRoot;
    extraOptions = [
      "--verbose=7"
      "--bind-address ${localIP}"
    ];
  };

  networking = {
    firewall = {
      trustedInterfaces = [ interface ];

      interfaces."${interface}" = {
        allowedTCPPorts = [
          53 # dns
          4011 # pixiecore
          config.services.pixiecore.port
          config.services.pixiecore.statusPort
        ];
        allowedUDPPorts = [
          53 #dns
          67 # dhcp
          68 # dhcp
          69 # tftp
        ];
      };
      connectionTrackingModules = [ "tftp" ];
    };
    nat.internalInterfaces = [ interface ];
  };

  systemd.network = {
    networks."40-${interface}" = {
      matchConfig.Name = interface;
      networkConfig = {
        ConfigureWithoutCarrier = true;
        #DHCPServer = true;
        Address = "${localIP}/24";
      };
      #dhcpServerConfig = {
      #  SendOption = [
      #    "0:string:bla"
      #    "67:string:ipxe.efi"
      #    "128:ipv4address:${localIP}"
      #  ];
      #};
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      interface=${interface}
      bind-interfaces

      # disable dns
      port=0

      dhcp-range=172.16.77.20,172.16.77.50
      log-dhcp

      enable-tftp
      tftp-root=${tftpRoot}
      pxe-service=0,"Raspberry Pi Boot"
    '';
  };
}
