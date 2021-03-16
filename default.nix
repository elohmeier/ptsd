{ pkgs, ... }:
{
  imports = [
    ./2configs
    ./3modules
    <home-manager/nixos>
  ];
  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ./5pkgs pkgs;
  };
}
