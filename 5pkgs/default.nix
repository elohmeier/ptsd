with import <ptsd/lib>;
self: super:
let
  subdirsOf = path:
    mapAttrs
      (name: _: path + "/${name}")
      (filterAttrs (_: eq "directory") (readDir path));
in
mapAttrs
  (_: flip self.callPackage { })
  (
    filterAttrs
      (_: dir: pathExists (dir + "/default.nix"))
      (subdirsOf ./.)
  )
# left for illustrative purposes
#  // {
# inherit (self.callPackage ./hasura {})
#   hasura-cli
#   hasura-graphql-engine
# };
