{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    attic-client
    btop
    cfssl
    colmena
    gcc
    gotenberg
    hcloud
    jq
    kubectl
    nix-tree
    pre-commit
    rustup
  ];
}
