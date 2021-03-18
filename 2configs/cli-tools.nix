{ config, lib, pkgs, ... }:
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
    screen
    tig
    tmux
    tree
    unzip
    vims.big
    wget
    shellcheck

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
    macchanger
    p7zip
    unrar
    mosh
    mkpasswd
    fd
    clang
  ];

  nixpkgs.config.allowUnfree = true; # required for unrar
}
