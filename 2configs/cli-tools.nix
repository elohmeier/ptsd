{ config, lib, pkgs, ... }:
let
  vims = pkgs.callPackage ./vims.nix { };
in
{
  environment.systemPackages = with pkgs; [
    bc
    bind
    bridge-utils
    file
    htop
    httpserve
    iftop
    iotop
    jq
    killall
    libfaketime
    mc
    ncdu
    nmap
    nnn
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
