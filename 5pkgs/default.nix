with import <ptsd/lib>;
self: super:
let
  subdirsOf = path:
    mapAttrs (name: _: path + "/${name}")
      (filterAttrs (_: eq "directory") (readDir path));
in
  #{
  #  burrow = self.callPackage ./burrow {};
  #}
mapAttrs (_: flip self.callPackage {})
  (
    filterAttrs (_: dir: pathExists (dir + "/default.nix"))
      (subdirsOf ./.)
  ) // {
  inherit (self.callPackage ./hasura {})
    hasura-cli
    hasura-graphql-engine
    ;
}
