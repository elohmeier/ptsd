{
  description = "ptsd";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    secrets.url = "/home/enno/repos/ptsd/dummy-secrets";
    secrets.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, secrets, ... }: {

    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    # defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;


    nixosConfigurations.eee1 = nixpkgs.lib.nixosSystem {
      system = "i686-linux";
      modules = [
        ./1systems/eee1/physical.nix
        #home-manager-unstable.nixosModules.home-manager
      ];
    };

  };
}