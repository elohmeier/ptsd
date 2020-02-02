{ config, lib, pkgs, ... }:

let
  vims = pkgs.callPackage ./vims.nix {};
in
{
  environment.systemPackages = with pkgs; [
    bc
    bind
    file
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
    vims.big
    #vims.small
    wget
  ];
}
