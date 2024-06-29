{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    attic-client
    bat
    btop
    cfssl
    colmena
    gcc
    gotenberg
    hcloud
    hl
    jless
    jq
    kubectl
    lazygit
    nix-tree
    pre-commit
    ripgrep
    rustup
  ];
}
