{ config, pkgs, ... }:
with import <ptsd/lib>;

let
  vims = pkgs.callPackage ../vims.nix {};
in
{
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.packages = [ vims.big ];
}
