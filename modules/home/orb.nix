{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    attic-client
    btop
    gcc
    jq
    pre-commit
    rustup
    nix-tree
  ];
}
