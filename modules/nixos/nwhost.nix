{ config, lib, pkgs, ... }:
{
  imports = [
    ./nwhost-mini.nix
  ];

  programs.fish.shellAliases = {
    l = "eza -al";
    la = "eza -al";
    lg = "eza -al --git";
    ll = "eza -l";
    ls = "eza";
    tree = "eza --tree";
  };

  environment.systemPackages = with pkgs; [
    bottom
    checkSSLCert
    cryptsetup
    dnsutils
    eza
    fd
    git
    macos-fix-filefoldernames
    mc
    ptsd-nnn
    ripgrep
  ];

  # programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault config.networking.firewall.enable;
}
