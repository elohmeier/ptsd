{ config, lib, pkgs, ... }:

# Tools you probably would not add to an ISO image

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs unstable;
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
    <ptsd/2configs/home/irssi.nix>
    <ptsd/2configs/home/mbsync.nix>
  ];

  home.packages = with pkgs; let
    wine = wineStaging.override { wineBuild = "wine32"; };
  in
    [
      unstable.vscodium
      wine
      (winetricks.override { wine = wine; })

      slack-dark

      unstable.jetbrains.pycharm-professional
      unstable.jetbrains.goland
      unstable.vscodium
      sqlitebrowser
      #filezilla
      libreoffice
      inkscape
      gimp
      #tor-browser-bundle-bin
      spotify
      xournalpp
      calibre
      unstable.xmind
      transmission-gtk

      chromium

      #thunderbird
      sylpheed

      #unstable.zoom-us

      pulseeffects

      #mucommander
      xorg.xev
      xorg.xhost

      gnome3.file-roller
      zathura
      zathura-single
      #nerdworks-motivation
      caffeine
      lguf-brightness

      #nitrokey-app
      #yubioath-desktop
      #yubikey-manager-qt
      keepassxc
      xcalib

      portfolio

      woeusb
      obs-studio

      # using unstable: "shakespeare" too old in 19.09
      # disabled: see https://github.com/NixOS/nixpkgs/pull/75527#issuecomment-584187640
      #unstable.hasura-graphql-engine
      #unstable.hasura-cli

      unstable.betaflight-configurator

      (pidgin-with-plugins.override { plugins = [ telegram-purple ]; })

      unstable.drone-cli
      openshift
      minishift
      neomutt
      cachix
      pyenv
      virtmanager
      virtviewer
      docker_compose
      nvi # needed for virsh
      dnsmasq
      mosh
      wireshark-qt
      freerdp
      screen
      sqlitebrowser
      nixpkgs-fmt
      asciinema
      gnumake
      qrencode
      nix-deploy
      hcloud
      dep2nix
      xca
      gcolor3
      vlc
      syncthing
      imagemagick
      youtube-dl
      spotify
      mpv
      drawio
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
      pcmanfm
      geckodriver
      smbclient
      unstable.mu-repo # not yet in 19.09
      file-rename
    ];

  # fix font antialiasing in mucommander
  home.sessionVariables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";

  programs.emacs.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    initExtra = ''
      # Johnnydecimal.com
      cjdfunction() {
        pushd ~/Pocket/*/*/$${1}*
      }
      export cjdfunction
      alias cjd="cjdfunction"
    '';
  };
}
