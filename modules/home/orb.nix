{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    gotenberg
    pre-commit
    rustup
    gcc
  ];
}
