{ config, lib, pkgs, ... }:
let
  universe = import ./universe.nix;
in
{
  imports = [
    ../3modules
    ./nwhost-mini.nix
  ];

  ptsd.nwacme = {
    enable = lib.mkDefault true;
    hostCert.enable = lib.mkDefault true;
  };

  ptsd.nwbackup = {
    enable = lib.mkDefault true;
  };

  environment.systemPackages = [
    pkgs."telegram.sh"
    pkgs.dnsutils
    pkgs.cryptsetup
    pkgs.tmux
  ];

  programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault true;

  system.fsPackages = [ pkgs.ntfs3g ];
}
