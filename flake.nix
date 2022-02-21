{
  description = "ptsd";

  inputs = {
    # use e.g. `nix build .#nixosConfigurations.XXX.config.system.build.toplevel --override-input nixpkgs github:NixOS/nixpkgs/83667ff` to update to specific commit
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    #nixpkgs.url = "/home/enno/repos/nixpkgs";
    nixpkgs-master.url = github:NixOS/nixpkgs/master;
    nixpkgs-local.url = "/home/enno/repos/nixpkgs";
    home-manager.url = github:nix-community/home-manager/release-21.11;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = github:numtide/flake-utils;
    nix-doom-emacs.url = github:nix-community/nix-doom-emacs;
    nix-doom-emacs.inputs.flake-utils.follows = "flake-utils";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    frix.url = "git+https://git.fraam.de/fraam/frix";
    #frix.url = "/home/enno/repos/frix";
    frix.inputs.nixpkgs.follows = "nixpkgs";
    frix.inputs.nixpkgs-master.follows = "nixpkgs-master";
    frix.inputs.flake-utils.follows = "flake-utils";
    frix.inputs.nixos-hardware.follows = "nixos-hardware";
    frix.inputs.home-manager.follows = "home-manager";
    nur.url = github:nix-community/NUR;
    fraamdb.url = "git+ssh://git@git.fraam.de/fraam/fraamdb";
    #fraamdb.url = "/home/enno/repos/fraamdb";
    fraamdb.inputs.nixpkgs.follows = "nixpkgs";

    mobile-nixos = {
      #url = github:NixOS/mobile-nixos;
      #url = github:elohmeier/mobile-nixos/ptsd;
      url = "/home/enno/repos/mobile-nixos";
      # flake = false;
    };
    mobile-nixos.inputs.nixpkgs.follows = "nixpkgs";
    mobile-nixos.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-master
    , nixpkgs-local
    , home-manager
    , nixos-hardware
    , flake-utils
    , nix-doom-emacs
    , frix
    , nur
    , mobile-nixos
    , fraamdb
    , ...
    }:

    let
      pkgOverrides = pkgs:
        let
          pkgs_master = import nixpkgs-master {
            config.allowUnfree = true;
            system = pkgs.system;
          };
        in
        super: (import ./5pkgs pkgs pkgs_master super) // (import "${frix}/5pkgs" pkgs pkgs_master super);
      nixosConfigurations =
        let
          defaultModules = [
            ({ pkgs, ... }:
              {
                nix.nixPath = [
                  "nixpkgs=${nixpkgs}"
                ];
                nixpkgs.config = {
                  allowUnfree = true;
                  #packageOverrides = import ./5pkgs pkgs pkgs_master;
                  #packageOverrides = import "${frix}/5pkgs" pkgs pkgs_master;
                  #packageOverrides = super: { } // (import ./5pkgs pkgs pkgs_master super) // (import "${frix}/5pkgs" pkgs pkgs_master super);
                  packageOverrides = pkgOverrides pkgs;
                };
                nixpkgs.overlays = [ nur.overlay ];
              })
          ];
          desktopModules = [
            "${frix}"
            ./2configs/users/enno.nix
            {
              nix.nixPath = [
                "home-manager=${home-manager}"
                "nixpkgs-master=${nixpkgs-master}"
              ];
            }
            home-manager.nixosModule
            ({ pkgs, ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.users.mainUser = { nixosConfig, ... }:
                  {
                    imports = [
                      nix-doom-emacs.hmModule
                      ./3modules/home
                    ];

                    # workaround https://github.com/nix-community/home-manager/issues/2333
                    disabledModules = [ "config/i18n.nix" ];
                    home.sessionVariables.LOCALE_ARCHIVE_2_27 = "${nixosConfig.i18n.glibcLocales}/lib/locale/locale-archive";
                    systemd.user.sessionVariables.LOCALE_ARCHIVE_2_27 = "${nixosConfig.i18n.glibcLocales}/lib/locale/locale-archive";
                  };
              })
          ];
        in
        {
          iso = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              #"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
              {
                console.keyMap = "de-latin1";
                services.xserver.layout = "de";
                i18n.defaultLocale = "de_DE.UTF-8";
                time.timeZone = "Europe/Berlin";
                networking = {
                  useNetworkd = true;
                  useDHCP = false;
                  wireless.enable = false;
                  wireless.iwd.enable = true;
                  interfaces.wlan0.useDHCP = true;
                  networkmanager.wifi.backend = "iwd";
                };
                #   system.activationScripts.configure-iwd = nixpkgs.lib.stringAfter [ "users" "groups" ] ''
                #     mkdir -p /var/lib/iwd
                #     cat >/var/lib/iwd/fraam.psk <<EOF
                #     [Security]
                #     PreSharedKey=
                #     Passphrase=
                #     EOF
                #   '';
                environment.systemPackages =
                  let
                    pkgs = import
                      nixpkgs
                      {
                        config.allowUnfree = true;
                        system = "x86_64-linux";
                      };
                  in
                  [ pkgs.vivaldi ];
              }
            ];
            # modules = defaultModules ++ desktopModules ++ [
            #   ./.
            #   ./2configs/mainUser.nix
            #   ./3modules/cli.nix
            #   "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            #   {
            #     home-manager.users.mainUser = { ... }: { home.stateVersion = "21.05"; };
            #     ptsd.cli = {
            #       enable = true;
            #       fish.enable = true;
            #       defaultShell = "fish";
            #     };
            #     services.getty.autologinUser = nixpkgs.lib.mkForce "enno";
            #   }
            # ];
          };

          rescue = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./2configs/profiles/minimal.nix
              ./2configs/hw/ws2019/kernel.nix
              ({ config, lib, pkgs, ... }: {
                console.keyMap = "de-latin1";
                i18n.defaultLocale = "en_US.UTF-8";
                i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
                environment.defaultPackages = [ ];
                boot.enableContainers = false;
                system.build.squashfsStore = pkgs.callPackage "${nixpkgs}/nixos/lib/make-squashfs.nix" {
                  storeContents = [ config.system.build.toplevel ];
                  comp = "xz -Xdict-size 100%";
                };
                system.build.update-rescue =
                  let
                    bootcfg = pkgs.writeText "rescue.conf" ''
                      title rescue
                      linux /efi/rescue/bzImage
                      initrd /efi/rescue/initrd
                      options init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
                    '';
                  in
                  pkgs.writeShellScriptBin "update-rescue" ''
                    echo updating rescue image
                    cp ${config.system.build.squashfsStore} /boot/rescue.squashfs
                    cp ${config.system.build.initialRamdisk}/initrd /boot/EFI/rescue/initrd
                    cp ${config.system.build.kernel}/bzImage /boot/EFI/rescue/bzImage
                    cp ${bootcfg} /boot/loader/entries/rescue.conf
                  '';
                fileSystems = {
                  "/" = {
                    fsType = "tmpfs";
                    options = [ "mode=0755" ];
                  };
                  "/efi" = {
                    device = "/dev/disk/by-id/nvme-Force_MP600_192482300001285612C9-part1";
                    neededForBoot = true;
                    noCheck = true;
                  };
                  "/nix/.ro-store" = {
                    fsType = "squashfs";
                    device = "/efi/rescue.squashfs";
                    options = [ "loop" ];
                    neededForBoot = true;
                  };
                  "/nix/.rw-store" = {
                    fsType = "tmpfs";
                    options = [ "mode=0755" ];
                    neededForBoot = true;
                  };
                  "/nix/store" = {
                    fsType = "overlay";
                    device = "overlay";
                    options =
                      [
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
                };
                boot.loader.grub.enable = false;
              })
            ];
          };

          apu2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/apu2/physical.nix
              home-manager.nixosModule
            ];
          };

          eee1 = nixpkgs.lib.nixosSystem {
            system = "i686-linux";
            modules = defaultModules ++ [
              ./1systems/eee1/physical.nix
              home-manager.nixosModule
            ];
          };

          htz1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/htz1/physical.nix
              home-manager.nixosModule
            ];
          };

          htz2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/htz2/physical.nix
              home-manager.nixosModule
            ];
          };

          htz3 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/htz3/physical.nix
              fraamdb.nixosModules.fraamdb
              home-manager.nixosModule
            ];
          };

          nas1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/nas1/physical.nix
            ];
          };

          rpi2 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi2/physical.nix
            ];
          };

          rpi4 = nixpkgs-master.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi4/config.nix
              ./1systems/rpi4/carberry.nix
              ./1systems/rpi4/desktop.nix
              ./1systems/rpi4/hardware.nix
              ./1systems/rpi4/mobile.nix
              nixos-hardware.nixosModules.raspberry-pi-4
              home-manager.nixosModule
              { fileSystems."/".fsType = "tmpfs"; }
            ];
            specialArgs = { inherit nixpkgs-master; };
          };

          # use `nix run .#rpi4-vm` to launch QEMU vm
          rpi4_vm = nixpkgs-master.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi4/config.nix
              ./1systems/rpi4/desktop.nix
              ./1systems/rpi4/mobile.nix
              ({ modulesPath, ... }: {
                imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
                virtualisation = {
                  memorySize = 4096;
                  resolution = { x = 800; y = 600; }; # RPi 7" Touchscreen Display has 800x480, 800x600 is closest available option
                  qemu.options = [ "-vga virtio" ];
                };
              })
            ];
            specialArgs = { inherit nixpkgs-master; };
          };

          rpi4_netboot = nixpkgs-master.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi4/config.nix
              ./1systems/rpi4/carberry.nix
              ./1systems/rpi4/hardware.nix
              nixos-hardware.nixosModules.raspberry-pi-4
              home-manager.nixosModule
              ({ modulesPath, ... }: {
                imports = [ (modulesPath + "/installer/netboot/netboot.nix") ];
              })
            ];
            specialArgs = { inherit nixpkgs-master; };
          };

          # build using `nix build .#nixosConfigurations.rpi4_sdimage.config.system.build.sdImage`
          rpi4_sdimage = nixpkgs-master.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi4/config.nix
              ./1systems/rpi4/carberry.nix
              ./1systems/rpi4/desktop.nix
              ./1systems/rpi4/hardware.nix
              ./1systems/rpi4/mobile.nix
              nixos-hardware.nixosModules.raspberry-pi-4
              home-manager.nixosModule
              ./1systems/rpi4/sd-image.nix
            ];
            specialArgs = { inherit nixpkgs-master; };
          };

          tp1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ desktopModules ++ [
              ./1systems/tp1/physical.nix
              nixos-hardware.nixosModules.lenovo-thinkpad-x280
            ];
          };

          ws1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ desktopModules ++ [
              ./1systems/ws1/physical.nix
            ];
            specialArgs = { inherit nixpkgs-master nixos-hardware home-manager pkgOverrides; };
          };

          ws2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ desktopModules ++ [
              ./1systems/ws2/physical.nix
            ];
          };

          # use `nix build .#nixosConfigurations.pine1.config.mobile.outputs.default` to build a disk image
          pine1 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              mobile-nixos.nixosModules.pine64-pinephone
              home-manager.nixosModule
              ({ pkgs, ... }:
                {
                  home-manager.users.mainUser = { ... }: {
                    nixpkgs.config = {
                      allowUnfree = true;
                      packageOverrides = pkgOverrides pkgs;
                    };
                    nixpkgs.overlays = [ nur.overlay ];
                  };
                })
              ./1systems/pine1/physical.nix
            ];
          };

          # use `nix run .#pine1-vm` to launch QEMU vm
          pine1_vm = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              home-manager.nixosModule
              ({ pkgs, ... }:
                {
                  home-manager.users.mainUser = { ... }: {
                    nixpkgs.config = {
                      allowUnfree = true;
                      packageOverrides = pkgOverrides pkgs;
                    };
                    nixpkgs.overlays = [ nur.overlay ];
                  };
                })
              ./1systems/pine1/config.nix
              ({ modulesPath, ... }: {
                imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
                virtualisation = {
                  memorySize = 2048;
                  qemu.options = [ "-vga virtio" ];
                };
                users.users.mainUser.password = "nixos";
                users.users.root.password = "nixos";
                ptsd.secrets.enable = false;
              })
            ];
          };

          pine2 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ desktopModules ++ [
              ./1systems/pine2/physical.nix
            ];
          };

          pine2_bootstrap = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ desktopModules ++ [
              ./1systems/pine2/physical.nix
              {
                ptsd.bootstrap = true;
              }
            ];
          };

          pine2_cross = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./1systems/pine2/physical.nix
              ({ lib, ... }: {
                nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform;
              })
            ];
          };

          gitlab-runner = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ({ modulesPath, ... }: {
                imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
              })
              ({ lib, pkgs, ... }: {
                services.gitlab-runner = {
                  enable = true;
                  services.nix = {
                    registrationConfigFile = pkgs.writeText "gitlab-runner-registration" ''
                      CI_SERVER_URL=https://git.fraam.de/
                      REGISTRATION_TOKEN=
                    '';
                    dockerImage = "alpine";
                    dockerVolumes = [
                      "/nix/store:/nix/store:ro"
                      "/nix/var/nix/db:/nix/var/nix/db:ro"
                      "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
                    ];
                    dockerDisableCache = true;
                    preBuildScript = pkgs.writeScript "setup-container" ''
                      mkdir -p -m 0755 /nix/var/log/nix/drvs
                      mkdir -p -m 0755 /nix/var/nix/gcroots
                      mkdir -p -m 0755 /nix/var/nix/profiles
                      mkdir -p -m 0755 /nix/var/nix/temproots
                      mkdir -p -m 0755 /nix/var/nix/userpool
                      mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
                      mkdir -p -m 1777 /nix/var/nix/profiles/per-user
                      mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
                      mkdir -p -m 0700 "$HOME/.nix-defexpr"

                      . ${pkgs.nix}/etc/profile.d/nix.sh

                      ${pkgs.nix}/bin/nix-env -i ${lib.concatStringsSep " " (with pkgs; [ nix cacert git openssh ])}

                      ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
                      ${pkgs.nix}/bin/nix-channel --update nixpkgs
                    '';
                    environmentVariables = {
                      ENV = "/etc/profile";
                      #USER = "root";
                      USER = "bldusr";
                      NIX_REMOTE = "daemon";
                      PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
                      NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
                    };
                    tagList = [ "nix" ];
                  };
                };
                users.groups.bldgrp = { };
                users.users.bldusr = { isSystemUser = true; group = "bldgrp"; };
                console.keyMap = "de-latin1";
                services.getty.autologinUser = "root";
              })
            ];
          };
        };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true; inherit system;
          config.packageOverrides = pkgOverrides pkgs;
        };

      in
      {
        apps = {
          pine1-vm = {
            type = "app";
            program = "${nixosConfigurations.pine1_vm.config.system.build.vm}/bin/run-pine1-vm";
          };

          rpi4-vm = {
            type = "app";
            program = "${nixosConfigurations.rpi4_vm.config.system.build.vm}/bin/run-rpi4-vm";
          };
        };
        packages = pkgs // {
          mk-pretty =
            let
              path = pkgs.lib.makeBinPath (with pkgs; [
                git
                nixpkgs-fmt
                ptsd-python3.pkgs.black
                python3Packages.isort
                gofumpt
              ]);
            in
            pkgs.writeShellScriptBin "mk-pretty" ''
              set -e
              export PATH=${path}
              ROOT=$(git rev-parse --show-toplevel)
              nixpkgs-fmt $ROOT/1systems
              nixpkgs-fmt $ROOT/2configs
              nixpkgs-fmt $ROOT/3modules
              nixpkgs-fmt $ROOT/5pkgs
              nixpkgs-fmt $ROOT/*.nix      
              black $ROOT/.
              isort $ROOT/5pkgs
              black $ROOT/src/*.pyw
              isort $ROOT/src/*.pyw
              gofumpt -w $ROOT/5pkgs
            '';
        };
        devShell = import ./shell.nix { inherit pkgs; };
      })
    // {
      inherit nixosConfigurations;
    };
}
