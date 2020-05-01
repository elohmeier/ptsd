{ config, lib, pkgs, ... }:

# Tools you probably would not add to an ISO image
let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs unstable;
  };
  py3 = pkgs.python37.override {
    packageOverrides = self: super: rec {
      black_nbconvert = super.callPackage ../../5pkgs/black_nbconvert {};
    };
  };
  pyenv = py3.withPackages (
    pythonPackages: with pythonPackages; [
      black
      black_nbconvert
      jupyterlab
      lxml
      keyring
      pdfminer
      pillow
      requests
      selenium
    ]
  );
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };
  obs-studio = unstable.obs-studio.overrideAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ unstable.addOpenGLRunpath ];
      postFixup = lib.optionalString pkgs.stdenv.isLinux ''
        # Set RUNPATH so that libcuda in /run/opengl-driver(-32)/lib can be found.
        # See the explanation in addOpenGLRunpath.
        addOpenGLRunpath $out/lib/lib*.so
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

  home.packages = with pkgs; let
    wine = wineStaging.override { wineBuild = "wine32"; };
  in
    [
      sshfs
      pdftk

      unstable.vscodium
      wine
      (winetricks.override { wine = wine; })

      slack-dark

      unstable.jetbrains.idea-ultimate
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

      thunderbird
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
      ffmpeg

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

      teamviewer
      discord
      mediathekview
      unstable.rclone

      unstable.tdesktop # telegram-desktop


      obs-studio
    ];

  home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
    rm -rf $HOME/.config/obs-studio/plugins
    mkdir -p $HOME/.config/obs-studio/plugins
    ln -sf ${obs-v4l2sink}/lib/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
  '';

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
