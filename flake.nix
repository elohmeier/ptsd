{
  description = "ptsd";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    nixpkgs-master.url = github:NixOS/nixpkgs/master;
    home-manager.url = github:nix-community/home-manager/release-21.05;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = github:numtide/flake-utils;
    #nix-doom-emacs.url = github:vlaci/nix-doom-emacs;
    #nix-doom-emacs.inputs.flake-utils.follows = "flake-utils";
    #nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    frix.url = "git+https://git.fraam.de/fraam/frix";
    frix.inputs.nixpkgs.follows = "nixpkgs";
    frix.inputs.nixpkgs-master.follows = "nixpkgs-master";
    frix.inputs.flake-utils.follows = "flake-utils";
    frix.inputs.nixos-hardware.follows = "nixos-hardware";
    frix.inputs.home-manager.follows = "home-manager";
    nur.url = github:nix-community/NUR;
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-master
    , home-manager
    , nixos-hardware
    , flake-utils
      #, nix-doom-emacs
    , frix
    , nur
    , ...
    }:

    let
      pkgOverrides = pkgs:
        let
          pkgs_master = import nixpkgs-master { system = pkgs.system; };
        in
        super: (import ./5pkgs pkgs pkgs_master super) // (import "${frix}/5pkgs" pkgs pkgs_master super);
      nixosConfigurations =
        let
          defaultModules = [
            ({ pkgs, ... }:
              {
                nix.nixPath = [
                  "home-manager=${home-manager}"
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
            {
              nix.nixPath = [
                "nixpkgs-master=${nixpkgs-master}"
              ];
            }
            home-manager.nixosModule
            ({ pkgs, ... }:
              {
                home-manager.users.mainUser = { ... }: {
                  #imports = [ nix-doom-emacs.hmModule ];
                  home.packages = (import "${frix}/2configs/hackertools.nix" { inherit pkgs; }).infosec_no_pyenv;
                  nixpkgs.config = {
                    allowUnfree = true;
                    packageOverrides = pkgOverrides pkgs;
                  };
                  nixpkgs.overlays = [ nur.overlay ];
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
              home-manager.nixosModule
            ];
          };

          nas1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/nas1/physical.nix
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
              })
              {
                virtualisation = {
                  memorySize = 4096;
                  resolution = { x = 800; y = 600; }; # RPi 7" Touchscreen Display has 800x480, 800x600 is closest available option
                  qemu.options = [ "-vga virtio" ];
                };
              }
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
        apps.rpi4-vm = {
          type = "app";
          program = "${nixosConfigurations.rpi4_vm.config.system.build.vm}/bin/run-rpi4-vm";
        };
        packages = pkgs // {
          mk-pretty =
            let
              path = pkgs.lib.makeBinPath (with pkgs; [
                git
                nixpkgs-fmt
                python3Packages.black
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
