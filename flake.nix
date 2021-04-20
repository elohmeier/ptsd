{
  description = "ptsd";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager/master;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }: {

    packages.x86_64-linux.cachix = nixpkgs.legacyPackages.x86_64-linux.cachix;

    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    # defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;


    nixosConfigurations = {
      eee1 = nixpkgs.lib.nixosSystem {
        system = "i686-linux";
        modules = [
          ./1systems/eee1/physical.nix
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
