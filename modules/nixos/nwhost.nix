{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./fish.nix
    ./nwhost-mini.nix
  ];

  environment.systemPackages = with pkgs; [
    bottom
    checkSSLCert
    cryptsetup
    dnsutils
    fd
    git
    macos-fix-filefoldernames
    mc
    ripgrep
  ];

  # programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault config.networking.firewall.enable;
}
