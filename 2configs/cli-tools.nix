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

    nixpkgs-fmt
    gnumake
    #(pass.withExtensions (ext: [ ext.pass-import ]))
    pass
    openssl
    lorri
    smartmontools
    gptfdisk
    gparted
    usbutils
    wirelesstools
    wpa_supplicant
    inetutils
    macchanger
    p7zip
    unrar
    mosh
    mkpasswd
  ];

  nixpkgs.config.allowUnfree = true; # required for unrar
}
