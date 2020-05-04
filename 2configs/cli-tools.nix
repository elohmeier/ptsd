{ config, lib, pkgs, ... }:
let
  vims = pkgs.callPackage ./vims.nix {};
in
{
  environment.systemPackages = with pkgs; [
    bc
    bind
    bridge-utils
    file
    htop
    iftop
    iotop
    jq
    killall
    mc
    ncdu
    nmap
    pssh
    pwgen
    ripgrep
    rmlint
    tig
    tmux
    tree
    unzip
    vims.big
    wget
  ];
}
