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
      ../../rpi4/sway.nix

      #../../rpi4/kodi.nix

      ({ modulesPath, config, lib, pkgs, ... }: {
        imports = [
          nixos-hardware.nixosModules.raspberry-pi-4
          home-manager.nixosModule
        ];

        boot.kernelParams = [ "ip=dhcp" ];

        boot.initrd.network.enable = true;
        boot.initrd.availableKernelModules = [ "overlay" ];
        boot.initrd.kernelModules = [ "overlay" ];

        # required networking config for successful nfsroot boot
        networking = {
          useNetworkd = lib.mkForce false;
          useDHCP = lib.mkForce false;
          interfaces.eth0.useDHCP = lib.mkForce false;
        };

        fileSystems."/" = {
          fsType = "tmpfs";
          options = [ "mode=0755" ];
        };

        fileSystems."/nix/.ro-store" = {
          fsType = "nfs";
          device = "${localIP}:/";
          options = [ "nfsvers=4" ];
          neededForBoot = true;
        };

        fileSystems."/nix/.rw-store" = {
          fsType = "tmpfs";
          options = [ "mode=0755" ];
          neededForBoot = true;
        };

        fileSystems."/nix/store" = {
          fsType = "overlay";
          device = "overlay";
          options = [
            "lowerdir=/nix/.ro-store"
            "upperdir=/nix/.rw-store/store"
            "workdir=/nix/.rw-store/work"
          ];
          depends = [
            "/nix/.ro-store"
            "/nix/.rw-store/store"
            "/nix/.rw-store/work"
          ];
        };

        boot.postBootCommands =
          ''
            # After booting, register the contents of the Nix store
            # in the Nix database in the tmpfs.
            ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration

            # nixos-rebuild also requires a "system" profile and an
            # /etc/NIXOS tag.
            touch /etc/NIXOS
            ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
          '';

        # https://github.com/raspberrypi/linux/issues/4020
        system.build.firmware =
          let
            configTxt = pkgs.writeText
              "config.txt"
              ''
                [pi4]
                kernel=Image
                initramfs initrd
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

                # required for Carberry
                enable_uart=1

                # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
                # when attempting to show low-voltage or overtemperature warnings.
                avoid_warnings=1

                # disable missing sdcard log spam
                dtparam=sd_poll_once=on
              '';

            cmdlineTxt = pkgs.writeText "cmdline.txt" "init=${bootSystem.config.system.build.toplevel}/init ${toString bootSystem.config.boot.kernelParams}";
          in
          pkgs.runCommand
            "firmware"
            { }
            ''
              mkdir -p $out
              (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $out/)

              # Add the config / cmdline
              cp ${configTxt} $out/config.txt
              cp ${cmdlineTxt} $out/cmdline.txt

              # Add pi4 specific files
              cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/armstub8-gic.bin
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb $out/
            '';

        system.build.nfsroot = pkgs.runCommand "nfsroot" { } ''
          closureInfo=${pkgs.closureInfo { rootPaths = [ config.system.build.toplevel ]; }}
          mkdir $out
          cp $closureInfo/registration nix-path-registration
          cp -r nix-path-registration $(cat $closureInfo/store-paths) $out
        '';
      })
    ];
    specialArgs = { inherit nixpkgs-master; };
  };

  tftpRoot = with bootSystem.config.system.build; pkgs.symlinkJoin {
    name = "ipxeBootDir";
    paths = [
      initialRamdisk
      kernel
      "${kernel}/dtbs" # rpi expects "overlays" folder on root level
      firmware
    ];
  };

in
{
  services.nfs.server = {
    enable = true;
    exports = ''
      ${bootSystem.config.system.build.nfsroot} 172.16.77.0/24(fsid=0,ro,async,no_root_squash,no_subtree_check)
    '';
  };

  networking = {
    firewall = {
      interfaces."${interface}" = {
        allowedTCPPorts = [
          53 # dns
          111 # nfs
          2049 # nfs
        ];
        allowedUDPPorts = [
          53 #dns
          67 # dhcp
          68 # dhcp
          69 # tftp
          111 # nfs
          2049 # nfs
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
