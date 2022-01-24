{ config, lib, pkgs, ... }:

{
  imports = [
    ./alertmanager.nix
    ./blackbox-exporter.nix
    ./fritzbox-exporter.nix
    ./quotes-exporter.nix
    ./server.nix
  ];
}
