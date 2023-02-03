{ config, lib, pkgs, ... }:
{
  imports = [
    ../3modules
    ./nwhost-mini.nix
  ];

  programs.fish.shellAliases = {
    l = "exa -al";
    la = "exa -al";
    lg = "exa -al --git";
    ll = "exa -l";
    ls = "exa";
    tree = "exa --tree";
  };

  environment.systemPackages = with pkgs; [
    bottom
    checkSSLCert
    cryptsetup
    dnsutils
    exa
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
