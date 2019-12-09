{ name }: let
  krops = (import <nixpkgs> {}).fetchgit {
    url = https://cgit.krebsco.de/krops/;
    rev = "v1.18.1";
    sha256 = "061ngm42xfr9grmchwzx6v3zmraych23xc1miimdsyd65y9hg4c5";
  };

  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" {};

  source = lib.evalSource [
    {
      nixpkgs.git = {
        clean.exclude = [ "/.version-suffix" ];
        ref = (lib.importJSON ./nixpkgs.json).rev;
        url = https://github.com/NixOS/nixpkgs;
      };

      ptsd.file = toString ./.;

      nixos-config.symlink = "ptsd/1systems/${name}/physical.nix";

      secrets.pass = {
        dir = "${lib.getEnv "HOME"}/.password-store";
        name = "hosts/${name}";
      };

      secrets-shared.pass = {
        dir = "${lib.getEnv "HOME"}/.password-store";
        name = "hosts-shared";
      };
    }
  ];
in
{
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A deploy)
  deploy =
    pkgs.krops.writeDeploy "deploy" {
      source = source;
      target = "root@${name}.host.nerdworks.de";
    };

  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A populate)  
  populate = pkgs.populate {
    source = source;
    target = lib.mkTarget "root@${name}.host.nerdworks.de";
  };
}
