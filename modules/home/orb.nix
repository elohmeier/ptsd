{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    attic-client
    btop
    gcc
    pre-commit
    rustup
  ];
}
