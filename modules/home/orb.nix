{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    gcc
    pre-commit
    rustup
  ];
}
