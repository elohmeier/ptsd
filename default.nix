{ pkgs, ... }:
{
  imports = [
    ./2configs
    ./3modules
  ];
  nixpkgs = {
    config.packageOverrides = import ./5pkgs pkgs;
  };
}
