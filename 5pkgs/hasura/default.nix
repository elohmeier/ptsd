# EL 2020-02-10:
# shameless copy from https://github.com/NixOS/nixpkgs/pull/75527.
# no local changes.
{ haskellPackages, haskell }:

with haskell.lib;

let
  pkgs = haskellPackages.override {
    overrides = self: super: {
      hasura-graphql-engine = self.callPackage ./graphql-engine.nix {};
      hasura-cli = self.callPackage ./cli.nix {};

      ci-info = self.callPackage ./ci-info.nix {};
      graphql-parser = self.callPackage ./graphql-parser.nix {};
      pg-client = self.callPackage ./pg-client.nix {};
      stm-hamt = doJailbreak (unmarkBroken super.stm-hamt);
      superbuffer = doJailbreak (unmarkBroken super.superbuffer);
      Spock-core = unmarkBroken super.Spock-core;
      stm-containers = unmarkBroken super.stm-containers;
    };
  };
in
{
  inherit (pkgs) hasura-graphql-engine hasura-cli;
}
