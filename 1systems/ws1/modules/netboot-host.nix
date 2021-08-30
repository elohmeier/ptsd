{ config
, lib
, pkgs
, nixpkgs-master
, nixos-hardware
, home-manager
, ...
}:

let
  interface = "enp39s0";
  localIP = "172.16.77.1";

  bootSystem = nixpkgs-master.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      ../../rpi4/config.nix

      ({ modulesPath, pkgs, ... }: {
        imports = [
          nixos-hardware.nixosModules.raspberry-pi-4
          home-manager.nixosModule
          (modulesPath + "/installer/netboot/netboot.nix")
        ];

        # https://github.com/raspberrypi/linux/issues/4020
        system.build.firmware =
          let
            configTxt = pkgs.writeText
              "config.txt"
              ''
                [pi3]
                kernel=u-boot-rpi3.bin

                [pi4]
                kernel=u-boot-rpi4.bin
                enable_gic=1
                armstub=armstub8-gic.bin

                # Otherwise the resolution will be weird in most cases, compared to
                # what the pi3 firmware does by default.
                disable_overscan=1

                # GPU/Display config
                dtoverlay=vc4-fkms-v3d
                gpu_mem=128                

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
          pkgs.runCommand
            "firmware"
            { }
            ''
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
    specialArgs = { inherit nixpkgs-master; };
  };

  # see https://github.com/ARM-software/u-boot/blob/master/doc/README.pxe
  pxelinuxConfig = pkgs.writeTextFile {
    name = "pxelinux-config";
    text = ''
      menu title Linux selections

      label nixos
        kernel Image
        append init=${bootSystem.config.system.build.toplevel}/init ${toString bootSystem.config.boot.kernelParams}
        initrd initrd
    
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
      "${kernel}/dtbs" # rpi expects "overlays" folder on root level
      firmware
      pxelinuxConfig
    ];
  };
in
{
  networking = {
    firewall = {
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
      dhcpServerConfig = {
        # requires systemd v248, see
        # https://github.com/systemd/systemd/commit/986c0edfcb9f69160658fd8a88cb72f0d7d208d3
        # (NixOS 21.05 has v247)
        #  SendOption = [
        #    "60:string:PXEClient"
        #    #"60:ipv4address:${localIP}"
        #     "128:ipv4address:${localIP}"
        #  ];
        #  SendVendorOption = [
        #    "6:uint8:3"
        #    "10:string:PXE"
        #    "9:string:Raspberry Pi Boot"
        #  ];
      };
    };
  };

  # for later use with systemd-networkd
  # services.atftpd = {
  #   enable = true;
  #   root = tftpRoot;
  #   extraOptions = [
  #     "--verbose=7"
  #     "--bind-address ${localIP}"
  #   ];
  # };


  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      interface=${interface}
      bind-interfaces

      dhcp-range=172.16.77.20,172.16.77.50
      dhcp-host=dc:a6:32:cb:6a:bc,rpi4,172.16.77.2
      log-dhcp

      enable-tftp
      tftp-root=${tftpRoot}
      pxe-service=0,"Raspberry Pi Boot"
    '';
  };
}
