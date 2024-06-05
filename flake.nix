{
  description = "ptsd";

  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:elohmeier/home-manager/release-24.05-darwin";
    };
    lanzaboote = {
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/lanzaboote/v0.3.0";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-rpi4.url = "github:elohmeier/nixpkgs/2bd04c7d2efbd5c7ce1d626baaa6303eb578dc27";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    nixcfg = {
      url = "github:elohmeier/nixcfg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix95 = {
      url = "github:elohmeier/nix95";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, treefmt-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
      imports = [ ./modules treefmt-nix.flakeModule ];
    };

  # outputs =
  #   { self
  #   , disko
  #   , flake-utils
  #   , home-manager
  #   , lanzaboote
  #   , nixos-hardware
  #   , nixpkgs
  #   , nixpkgs-unstable
  #   , nixpkgs-unstable-rpi4
  #   , ...
  #   }:
  #
  # flake-utils.lib.eachDefaultSystem
  #   (system:
  #   {
  #     packages =
  #       let
  #         pkgs = import nixpkgs-unstable {
  #           inherit system;
  #           overlays = [ self.overlay ];
  #           config.allowUnfree = true;
  #         };
  #       in
  #       {
  #         deploy-rpi4_scangw = pkgs.writeShellScriptBin "deploy-rpi4_scangw" ''
  #           echo "building..."
  #           nix copy --to ssh://root@rpi4.fritz.box ${self.nixosConfigurations.rpi4_scangw.config.system.build.toplevel}
  #           echo "activating..."
  #           ssh -t root@rpi4.fritz.box "${self.nixosConfigurations.rpi4_scangw.config.system.build.toplevel}/bin/switch-to-configuration switch"
  #         '';
  #       };
  #   })
  # // {
  #   overlay = import ./modules/flake/overlays.nix;
  #
  #   nixosConfigurations =
  #     {
  #       tp4 = nixpkgs.lib.nixosSystem
  #         {
  #           system = "x86_64-linux";
  #           modules = [
  #             home-manager.nixosModule
  #             self.nixosModules.defaults
  #             self.nixosModules.generic
  #             self.nixosModules.generic-desktop
  #             self.nixosModules.generic-disk
  #             self.nixosModules.tp4
  #           ];
  #         };
  #
  #       htz2 = nixpkgs.lib.nixosSystem
  #         {
  #           system = "x86_64-linux";
  #           modules = [
  #             self.nixosModules.secrets
  #             ./1systems/htz2/physical.nix
  #           ];
  #         };
  #
  #       rpi4_scangw = nixpkgs-unstable-rpi4.lib.nixosSystem
  #         {
  #           system = "aarch64-linux";
  #           modules = [
  #             ./1systems/rpi4_scangw
  #             nixos-hardware.nixosModules.raspberry-pi-4
  #             self.nixosModules.defaults
  #             self.nixosModules.nix-persistent
  #             self.nixosModules.ports
  #             self.nixosModules.secrets
  #             self.nixosModules.tailscale
  #             self.nixosModules.wireguard
  #             {
  #               nixpkgs.pkgs = import nixpkgs-unstable
  #                 {
  #                   system = "aarch64-linux";
  #                   overlays = [ self.overlay ];
  #                   config.allowUnfree = true;
  #                 };
  #             }
  #           ];
  #         };
  #
  #       # pine2 = nixpkgs.lib.nixosSystem
  #       #   {
  #       #     system = "aarch64-linux";
  #       #     modules = [
  #       #       ./1systems/pine2/physical.nix
  #       #     ];
  #       #   };
  #       #
  #       # pine2_cross = nixpkgs.lib.nixosSystem
  #       #   {
  #       #     system = "x86_64-linux";
  #       #     modules = [
  #       #       ./1systems/pine2/physical.nix
  #       #       ({ lib, ... }: { nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform; })
  #       #     ];
  #       #   };
  #     };
  #
  #   homeConfigurations =
  #     {
  #       # sway_pine2 = home-manager.lib.homeManagerConfiguration {
  #       #   system = "aarch64-linux";
  #       #   username = "enno";
  #       #   homeDirectory = "/home/enno";
  #       #   stateVersion = "21.11";
  #       #
  #       #   configuration = { config, pkgs, ... }: {
  #       #
  #       #     imports = desktopImports ++ [
  #       #       ./2configs/home/foot.nix
  #       #       ./2configs/home/i3status.nix
  #       #       ./2configs/home/sway.nix
  #       #       ./2configs/home/xdg.nix
  #       #     ];
  #       #
  #       #     nixpkgs.config = {
  #       #       allowUnfree = true;
  #       #       packageOverrides = pkgOverrides pkgs;
  #       #     };
  #       #   };
  #       # };
  #
  #
  #
  #       macos-luisa = home-manager.lib.homeManagerConfiguration {
  #         pkgs = import nixpkgs-unstable {
  #           system = "aarch64-darwin";
  #           overlays = [ self.overlay ];
  #           config.allowUnfree = true;
  #         };
  #
  #         modules = [
  #           ./2configs/home
  #           ./2configs/home/macos-luisa.nix
  #         ];
  #       };
  #     };
  # };
}
