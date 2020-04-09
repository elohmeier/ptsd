{ config, lib, pkgs, ... }:

# Tools you probably would not add to an ISO image
let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs unstable;
  };
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };
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

  # add nvidia encoder support to OBS
  obs-studio = unstable.obs-studio.overrideAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        unstable.linuxPackages_latest.nvidiaPackages.stable
      ];
      postInstall = ''
        wrapProgram $out/bin/obs \
          --prefix "LD_LIBRARY_PATH" : "${unstable.xorg.libX11.out}/lib:${unstable.vlc}/lib:${unstable.linuxPackages_latest.nvidiaPackages.stable}/lib"
      '';
    }
  );
  obs-v4l2sink = unstable.libsForQt5.callPackage ../../5pkgs/obs-v4l2sink { obs-studio = obs-studio; };
in
{
  imports = [
    <ptsd/2configs/home/irssi.nix>
    <ptsd/2configs/home/mbsync.nix>
  ];

  home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
    rm -rf $HOME/.config/obs-studio/plugins
    mkdir -p $HOME/.config/obs-studio/plugins
    ln -sf ${obs-v4l2sink}/lib/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
  '';

  home.packages = with pkgs; let
    wine = wineStaging.override { wineBuild = "wine32"; };
  in
    [
      obs-studio

      pdftk

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

      #thunderbird
      sylpheed

      unstable.zoom-us

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
      ffmpeg-full

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
      #nvi # needed for virsh # broken in 20.03 as of 2020-04-03
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
      mu-repo
      file-rename

      sublime3
    ];

  programs.chromium = {
    enable = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "chromium" ];
  };

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
