{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bc
    bind
    htop
    iftop
    iotop
    killall
    mc
    ncdu
    nmap
    pssh
    pwgen
    ripgrep
    rmlint
    tig
    tree
    unzip
    wget
  ];
}
