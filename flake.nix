{
  description = "ptsd";

  inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-config = {
      url = "github:elohmeier/nvim-config";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix95 = {
      url = "github:elohmeier/nix95";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcfg = {
      url = "github:elohmeier/nixcfg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      imports = [
        ./flake
        ./modules
      ];
    };

  # outputs =
  #   { self
  #   , disko
  #   , flake-utils
  #   , home-manager
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
