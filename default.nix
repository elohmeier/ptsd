{ pkgs, ... }:
{
  imports = [
    ./2configs
    ./3modules
  ];
  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ./5pkgs pkgs;
  };
}
