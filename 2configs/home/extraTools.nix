{ config, lib, pkgs, ... }:

# Tools you probably would not add to an ISO image
let
  unstable = import <nixpkgs-unstable> {
    config = {
      allowUnfree = true;
    };
  };
  py3 = pkgs.python37.override {
    packageOverrides = self: super: rec {
      black_nbconvert = super.callPackage ../../5pkgs/black_nbconvert { };
    };
  };
  pyenv = py3.withPackages (
    pythonPackages: with pythonPackages; [
      black
      black_nbconvert
      jupyterlab
      lxml
      keyring
      nbconvert
      pdfminer
      pillow
      requests
      selenium
    ]
  );
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };
  obs-studio = pkgs.obs-studio.overrideAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.addOpenGLRunpath ];
      postFixup = lib.optionalString pkgs.stdenv.isLinux ''
        # Set RUNPATH so that libcuda in /run/opengl-driver(-32)/lib can be found.
        # See the explanation in addOpenGLRunpath.
        addOpenGLRunpath $out/lib/lib*.so
      '';
    }
  );
  obs-v4l2sink = pkgs.libsForQt5.callPackage ../../5pkgs/obs-v4l2sink { obs-studio = obs-studio; };
  my-ffmpeg =
    (
      # waits for https://github.com/NixOS/nixpkgs/pull/87588
      pkgs.ffmpeg-full.overrideAttrs (
        old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.addOpenGLRunpath ];
          postFixup = ''
            addOpenGLRunpath $out/lib/libavcodec.so*
          '';
        }
      )
    ).override {
      nonfreeLicensing = true;
      fdkaacExtlib = true;
      ffplayProgram = false;
      ffprobeProgram = false;
      qtFaststartProgram = false;
    }
  ;
in
{
  imports = [
    <ptsd/2configs/home/irssi.nix>
    <ptsd/2configs/home/mbsync.nix>
  ];

  home.packages = with pkgs; let
    mywine = wine.override { wineBuild = "wine32"; wineRelease = "staging"; };
  in
  [
    sshfs
    pdftk
    mywine
    (winetricks.override { wine = mywine; })
    slack-dark
    jetbrains.idea-ultimate
    jetbrains.goland
    jetbrains.pycharm-professional
    vscodium
    sqlitebrowser
    #filezilla
    libreoffice
    inkscape
    gimp
    #tor-browser-bundle-bin
    xournalpp
    calibre
    xmind
    transmission-gtk
    sylpheed
    zoom-us
    #pulseeffects
    xorg.xev
    xorg.xhost
    gnome3.file-roller
    zathura
    zathura-single
    #nerdworks-motivation
    caffeine
    lguf-brightness
    keepassxc
    xcalib
    unstable.portfolio
    woeusb
    my-ffmpeg

    unstable.betaflight-configurator
    dbeaver
    drone-cli
    openshift
    minishift
    cachix
    pyenv
    virtmanager
    virtviewer
    docker_compose
    #nvi # needed for virsh # broken in 20.03 as of 2020-04-03
    dnsmasq
    wireshark-qt
    freerdp
    screen
    sqlitebrowser
    asciinema
    gnumake
    qrencode
    #nix-deploy
    #hcloud
    dep2nix
    xca
    gcolor3
    vlc
    syncthing
    imagemagick
    youtube-dl
    unstable.spotify
    vlc
    drawio
    geckodriver
    smbclient
    mu-repo
    file-rename
    #sublime3
    teamviewer
    discord
    mediathekview
    #(pkgs.callPackage <nixpkgs-unstable/pkgs/applications/networking/sync/rclone> {})
    unstable.rclone
    # telegram-desktop
    #(
    #  pkgs.qt5.callPackage <nixpkgs-unstable/pkgs/applications/networking/instant-messengers/telegram/tdesktop> {
    #    tl-expected = (pkgs.callPackage <nixpkgs-unstable/pkgs/development/libraries/tl-expected> {});
    #  }
    #)
    unstable.tdesktop # faster (build takes long on tp1)
    obs-studio
    gnome3.evolution
    go
    delve
    bitwarden-cli
    nbconvert
    peek
    hidclient
    fava
    unstable.AusweisApp2
    (
      unstable.ffmpeg-normalize.override {
        ffmpeg_3 = my-ffmpeg;
      }
    )
    weatherbg
    shrinkpdf
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


  home.sessionVariables = {
    GOPATH = "/home/enno/go";

    # fix font antialiasing in mucommander
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
  };

  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    initExtra = ''
      # Johnnydecimal.com
      cjdfunction() {
        pushd ~/Pocket/*/*/''${1}*
      }
      export cjdfunction
      alias cjd="cjdfunction"
    '';
  };
}
