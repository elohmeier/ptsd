{ config, pkgs, ... }:
with import <ptsd/lib>;

let
  vim = pkgs.callPackage ../../5pkgs/vim-customized {};
in
{
  home.sessionVariables = {
    EDITOR = "${vim}/bin/vim";
  };

  home.packages = [ vim ];
}
