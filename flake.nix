{
  description = "ptsd";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager/master;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            config.allowUnfree = true; inherit system;
          };
        in
        {
          packages = flake-utils.lib.flattenTree {
            cachix = pkgs.cachix;
            ffmpeg =
              pkgs.ffmpeg-full.override {
                nonfreeLicensing = true;
                fdkaacExtlib = true;
                qtFaststartProgram = false;
              };
            nwhass = pkgs.callPackage ./5pkgs/nwhass { };
          };
        })
    // {

      nixosConfigurations = {
        eee1 = nixpkgs.lib.nixosSystem {
          system = "i686-linux";
          modules = [
            ./1systems/eee1/physical.nix
            home-manager.nixosModule
          ];
        };

        nas1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./1systems/nas1/physical.nix
            home-manager.nixosModule
          ];
        };

        tp1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./1systems/tp1/physical.nix
            home-manager.nixosModule
            nixos-hardware.nixosModules.lenovo-thinkpad-x280
          ];
        };

        ws1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./1systems/ws1/physical.nix
            home-manager.nixosModules.home-manager
          ];
        };

        ws2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./1systems/ws2/physical.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}
