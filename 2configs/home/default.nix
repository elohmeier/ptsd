{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
  py3 = pkgs.python37;
  pyenv = py3.withPackages (
    pythonPackages: with pythonPackages; [
      black
      jupyterlab
      lxml
      keyring
      pdfminer
      pillow
      requests
      selenium
    ]
  );
in
{
  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/gpg.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/zsh.nix>

    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.packageOverrides = import ../../5pkgs pkgs;
    overlays = [
      (import ../../submodules/nix-writers/pkgs)
    ];
  };

  home.sessionVariables = {
    PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    pyenv
    nixpkgs-fmt
    gnumake
    (pass.withExtensions (ext: [ ext.pass-import ]))
    openssl
    efitools
    tpm2-tools
    lorri
    smartmontools
    gptfdisk
    gparted
    efibootmgr
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
}
