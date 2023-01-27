{ lib, pkgs, ... }:

let
  # generate using node2nix -i collection.json -16 -c node-composition.nix
  myNodePkgs = pkgs.callPackage ./node-composition.nix { };
  pkgNames = builtins.fromJSON (builtins.readFile ./collection.json);
  pkgJson = pkgs.writeTextFile {
    name = "package.json";
    destination = "/package.json";
    text = (builtins.toJSON {
      dependencies = (builtins.listToAttrs (builtins.map
        (name: {
          name = name;
          value = "*";
        })
        pkgNames));
    });
  };
in
pkgs.symlinkJoin {
  name = "coc-extensions";
  paths = (builtins.map (name: "${myNodePkgs.${name}}/lib") pkgNames) ++ [ pkgJson ];
}
