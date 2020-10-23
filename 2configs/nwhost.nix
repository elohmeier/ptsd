{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/3modules>
    <ptsd/2configs/acme-nwhost-cert.nix>
    <ptsd/2configs/nwhost-mini.nix>
  ];

  ptsd.nwtelegraf.enable = lib.mkDefault true;

  ptsd.nwmonit = {
    enable = lib.mkDefault true;
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
