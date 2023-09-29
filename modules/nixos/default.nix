{ self, lib, withSystem, ... }:
let
  nixosSystemFor = system: modules:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib; };
      modules = [
        {
          _module.args = {
            pkgs = lib.mkForce pkgs;
          };
        }
        self.nixosModules.default
      ] ++ modules;
    };

in
{
  flake.nixosModules = rec {
    default = { };

    dradis = ./dradis.nix;
    hcloud = ./hcloud;
  };

  flake.nixosConfigurations.lene-gotthard-striebitz = nixosSystemFor "aarch64-linux" [
    self.nixosModules.hcloud
    self.nixosModules.dradis
    { _module.args.nixinate = { host = "128.140.113.13"; sshUser = "root"; buildOn = "remote"; }; }
  ];
}


