{ name, desktop ? false, unstable ? false }: let
  #krops = (import <nixpkgs> {}).fetchgit {
  #  url = https://cgit.krebsco.de/krops/;
  #  rev = "v1.18.1";
  #  sha256 = "061ngm42xfr9grmchwzx6v3zmraych23xc1miimdsyd65y9hg4c5";
  #};

  krops = ./submodules/krops;

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
        #dir = "${lib.getEnv "HOME"}/.password-store";
        dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
        name = "hosts/${name}";
      };

      secrets-shared.pass = {
        dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
        name = "hosts-shared";
      };
    }

    (
      lib.optionalAttrs (unstable || desktop) {
        nixpkgs-unstable.git = {
          clean.exclude = [ "/.version-suffix" ];
          ref = (lib.importJSON ./nixpkgs-unstable.json).rev;
          url = https://github.com/NixOS/nixpkgs;
        };
      }
    )

    (
      lib.optionalAttrs desktop {
        client-secrets.pass = {
          dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
          name = "clients";
        };

        ci.git = {
          ref = "e3b62cd62ec0537716fb3d8af1242c6b470befee";
          url = "git@git.nerdworks.de:nerdworks/ci.git";
        };

        secrets-eee1.pass = {
          dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
          name = "hosts/eee1";
        };
      }
    )
  ];

in
{
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A deploy)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME --arg desktop true -A deploy)
  deploy =
    pkgs.krops.writeDeploy "deploy" {
      source = source;
      target = "root@${name}.host.nerdworks.de";
    };

  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A populate)  
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME --arg desktop true -A populate)  
  populate = pkgs.populate {
    source = source;
    target = lib.mkTarget "root@${name}.host.nerdworks.de";
  };
}
