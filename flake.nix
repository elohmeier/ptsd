{
  description = "ptsd";

  inputs = {
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:elohmeier/home-manager/master-darwin";
    lanzaboote.inputs.flake-utils.follows = "flake-utils";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    nixinate.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixinate.url = "github:elohmeier/nixinate";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable-rpi4.url = "github:elohmeier/nixpkgs/6afb867d477dd0bc61f56a7c2cc514673f5f75d2";
    nixpkgs-unstable.url = "github:elohmeier/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs =
    { self
    , disko
    , flake-utils
    , home-manager
    , lanzaboote
    , nixinate
    , nixos-hardware
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-unstable-rpi4
    , ...
    }:

    flake-utils.lib.eachDefaultSystem
      (system:
      {
        packages =
          let
            pkgs = import nixpkgs-unstable {
              inherit system;
              overlays = [ self.overlay ];
              config.allowUnfree = true;
            };
          in
          {
            deploy-rpi4_scangw = pkgs.writeShellScriptBin "deploy-rpi4_scangw" ''
              echo "building..."
              nix copy --to ssh://root@rpi4.fritz.box ${self.nixosConfigurations.rpi4_scangw.config.system.build.toplevel}
              echo "activating..."
              ssh -t root@rpi4.fritz.box "${self.nixosConfigurations.rpi4_scangw.config.system.build.toplevel}/bin/switch-to-configuration switch"
            '';
          };
      })
    // {
      apps = nixinate.nixinate.aarch64-darwin self;

      overlay = import ./5pkgs/overlay.nix;

      nixosModules = {
        defaults = import ./2configs/defaults.nix;
        generic = import ./2configs/generic.nix;
        generic-desktop = import ./2configs/generic-desktop.nix;
        generic-disk = import ./2configs/generic-disk.nix;
        networkmanager = import ./2configs/networkmanager.nix;
        nix-persistent = import ./2configs/nix-persistent.nix;
        secrets = import ./3modules/secrets.nix;
        tailscale = import ./3modules/tailscale.nix;
        tp3 = import ./2configs/tp3.nix;
        tp4 = import ./2configs/tp4.nix;
        users = import ./2configs/users;
        wireguard = import ./3modules/wireguard.nix;
      };

      nixosConfigurations =
        {
          tp3 = nixpkgs-unstable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              disko.nixosModules.disko
              home-manager.nixosModule
              lanzaboote.nixosModules.lanzaboote
              self.nixosModules.defaults
              self.nixosModules.networkmanager
              self.nixosModules.nix-persistent
              self.nixosModules.secrets
              self.nixosModules.tailscale
              self.nixosModules.tp3
              self.nixosModules.users
              self.nixosModules.wireguard
              {
                nixpkgs.pkgs = import nixpkgs-unstable
                  {
                    system = "x86_64-linux";
                    overlays = [ self.overlay ];
                    config.allowUnfree = true;
                  };
              }
            ];
          };

          tp4 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = [
                home-manager.nixosModule
                self.nixosModules.defaults
                self.nixosModules.generic
                self.nixosModules.generic-desktop
                self.nixosModules.generic-disk
                self.nixosModules.tp4
                { _module.args.nixinate = { host = "tp4.fritz.box"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          htz1 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = [
                ./1systems/htz1/physical.nix
                { _module.args.nixinate = { host = "htz1.nn42.de"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          htz2 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = [
                ./1systems/htz2/physical.nix
                { _module.args.nixinate = { host = "htz2.nn42.de"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          rpi4_scangw = nixpkgs-unstable-rpi4.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = [
                ./1systems/rpi4_scangw
                nixos-hardware.nixosModules.raspberry-pi-4
              ];
            };

          pine2 = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = [
                ./1systems/pine2/physical.nix
              ];
            };

          pine2_cross = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = [
                ./1systems/pine2/physical.nix
                ({ lib, ... }: { nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform; })
              ];
            };

          utmvm_nixos_3 = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = [
                home-manager.nixosModule
                self.nixosModules.generic
                self.nixosModules.generic-disk
                self.nixosModules.utmvm-nixos-3
                { _module.args.nixinate = { host = "192.168.74.3"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };
        };

      homeConfigurations =
        {
          xfce95 = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs-unstable {
              system = "x86_64-linux";
              overlays = [ self.overlay ];
              config.allowUnfree = true;
            };

            modules = [
              ./2configs/home
              ./2configs/home/fish.nix
              ./2configs/home/fonts.nix
              ./2configs/home/git.nix
              ./2configs/home/gpg.nix
              ./2configs/home/neovim.nix
              ./2configs/home/packages.nix
              ./2configs/home/ssh.nix
              ./2configs/home/tmux.nix
              ./2configs/home/xdg-fixes.nix
              ./2configs/home/tp3.nix
              { home.stateVersion = "23.05"; }
            ];
          };

          # sway_pine2 = home-manager.lib.homeManagerConfiguration {
          #   system = "aarch64-linux";
          #   username = "enno";
          #   homeDirectory = "/home/enno";
          #   stateVersion = "21.11";
          #
          #   configuration = { config, pkgs, ... }: {
          #
          #     imports = desktopImports ++ [
          #       ./2configs/home/foot.nix
          #       ./2configs/home/i3status.nix
          #       ./2configs/home/sway.nix
          #       ./2configs/home/xdg.nix
          #     ];
          #
          #     nixpkgs.config = {
          #       allowUnfree = true;
          #       packageOverrides = pkgOverrides pkgs;
          #     };
          #   };
          # };


          macos-enno = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs-unstable {
              system = "aarch64-darwin";
              overlays = [ self.overlay ];
              config.allowUnfree = true;
            };

            modules = [
              ./2configs/home
              ./2configs/home/darwin-defaults.nix
              ./2configs/home/fish.nix
              ./2configs/home/fonts.nix
              ./2configs/home/git.nix
              ./2configs/home/gpg.nix
              ./2configs/home/macos-enno.nix
              ./2configs/home/neovim.nix
              ./2configs/home/packages.nix
              ./2configs/home/paperless.nix
              ./2configs/home/ssh.nix
              ./2configs/home/tmux.nix
              ./2configs/home/xdg-fixes.nix
            ];
          };

          macos-luisa = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs-unstable {
              system = "aarch64-darwin";
              overlays = [ self.overlay ];
              config.allowUnfree = true;
            };

            modules = [
              ./2configs/home
              ./2configs/home/macos-luisa.nix
            ];
          };
        };
    };
}


