{
  description = "ptsd";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    home-manager.url = github:nix-community/home-manager/release-21.05;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = github:numtide/flake-utils;
    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
    nix-doom-emacs.inputs.flake-utils.follows = "flake-utils";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, flake-utils, nix-doom-emacs, ... }:

    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            config.allowUnfree = true; inherit system;
          };
        in
        {
          packages = flake-utils.lib.flattenTree {
            art = pkgs.callPackage ./5pkgs/art { };
            cachix = pkgs.cachix;
            ffmpeg =
              pkgs.ffmpeg-full.override {
                nonfreeLicensing = true;
                fdkaacExtlib = true;
                qtFaststartProgram = false;
              };
            hass-bs53 = (pkgs.callPackage ./5pkgs/home-assistant-variants { }).bs53;
            hass-dlrg = (pkgs.callPackage ./5pkgs/home-assistant-variants { }).dlrg;
          };
          devShell = import ./shell.nix { inherit pkgs; };
        })
    // {

      nixosConfigurations =
        let
          defaultModules = [{
            nix.nixPath = [
              "home-manager=${home-manager}"
              "nixpkgs=${nixpkgs}"
            ];
          }];
          desktopModules = [
            home-manager.nixosModule
            {
              home-manager.users.mainUser = { ... }: {
                imports = [ nix-doom-emacs.hmModule ];
              };
            }
          ];
        in
        {
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
              home-manager.nixosModule
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
