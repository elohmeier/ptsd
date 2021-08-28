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
    frix.url = "git+ssh://git@git.fraam.de/fraam/frix";
    frix.inputs.nixpkgs.follows = "nixpkgs";
    frix.inputs.flake-utils.follows = "flake-utils";
    frix.inputs.nixos-hardware.follows = "nixos-hardware";
    frix.inputs.home-manager.follows = "home-manager";
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
    , ...
    }:

    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs_master = import nixpkgs-master { inherit system; };
        packages = import nixpkgs {
          config.allowUnfree = true; inherit system;
          config.packageOverrides = import ./5pkgs packages pkgs_master;
        };
      in
      {
        inherit packages;
        devShell = import ./shell.nix { pkgs = packages; };
      })
    // {

      nixosConfigurations =
        let
          defaultModules = [
            ({ pkgs, ... }:
              let
                pkgs_master = import nixpkgs-master { system = pkgs.system; };
              in
              {
                nix.nixPath = [
                  "home-manager=${home-manager}"
                  "nixpkgs=${nixpkgs}"
                ];
                nixpkgs.config = {
                  allowUnfree = true;
                  packageOverrides = import ./5pkgs pkgs pkgs_master;
                };
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
              let
                pkgs_master = import nixpkgs-master { system = pkgs.system; };
              in
              {
                home-manager.users.mainUser = { ... }: {
                  #imports = [ nix-doom-emacs.hmModule ];
                  home.packages = (import "${frix}/2configs/hackertools.nix" { inherit pkgs; }).infosec_no_pyenv;
                  nixpkgs.config = {
                    allowUnfree = true;
                    packageOverrides = import ./5pkgs pkgs pkgs_master;
                  };
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

          rpi4 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi4/physical.nix
            ];
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
            specialArgs = { inherit nixpkgs nixos-hardware; };
          };

          ws2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ desktopModules ++ [
              ./1systems/ws2/physical.nix
            ];
          };
        };
    };
}
