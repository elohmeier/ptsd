{ config, lib, modulesPath, pkgs, home-manager, nixpkgs-master, nixos-hardware, ... }:

let
  interface = "enp39s0";
  localIP = "172.16.77.1";

  bootSystem = nixpkgs-master.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      nixos-hardware.nixosModules.raspberry-pi-4
      home-manager.nixosModule
      (modulesPath + "/installer/netboot/netboot.nix")
      ../../..
      #../../../2configs/fish.nix

      ({ pkgs, ... }: {
        boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
        #boot.kernelParams = [ "nomodeset" ];

        hardware.raspberry-pi."4".fkms-3d.enable = true;

        hardware.opengl = {
          enable = true;
          driSupport = true;
        };

        nix.nixPath = [
          #          "home-manager=${home-manager}"
          "nixpkgs=${nixpkgs-master}"
        ];

        console.keyMap = "de-latin1";

        programs.sway = {
          enable = true;
          extraPackages = with pkgs; [
            foot
            dmenu
          ];
        };

        environment.variables = {
          # enable touchscreen support in firefox
          MOZ_USE_XINPUT2 = 1;
        };

        # initrd shouldn't get too large...
        # environment.systemPackages = with pkgs; [
        #   firefox
        #   glxinfo
        # ];

        networking = {
          useNetworkd = true;
          useDHCP = false;
          hostName = "rpi4";
          interfaces.eth0.useDHCP = true;
        };

        users.users.enno = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "video" ];
          initialHashedPassword = "";
          openssh.authorizedKeys.keys =
            let
              sshPubKeys = import ../../../2configs/users/ssh-pubkeys.nix; in
            [
              sshPubKeys.sshPub.enno_yubi41
              sshPubKeys.sshPub.enno_yubi49
            ];
          #          shell = pkgs.fish;
        };


        programs.bash = {
          loginShellInit = ''
            # If running from tty1 start sway
            if [ "$(tty)" = "/dev/tty1" ]; then
              # pass sway log output to journald
              exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --my-next-gpu-wont-be-nvidia
            fi
          '';
        };

        home-manager.users.enno = { config, nixosConfig, pkgs, ... }:
          {
            imports = [
              #../../../2configs/home/fish.nix
            ];

            wayland.windowManager.sway = {
              enable = true;
              config = {
                input = {
                  "*" = {
                    xkb_layout = "de";
                  };

                  raspberrypi-ts = {
                    map_to_output = "DSI-1";
                  };
                };
                modifier = "Mod4";
                terminal = "${pkgs.foot}/bin/foot";
              };
            };

            home.stateVersion = "21.05";
          };

        services.openssh.enable = true;
        services.getty.autologinUser = "enno";
        security.sudo = {
          enable = true;
          wheelNeedsPassword = false;
        };

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
