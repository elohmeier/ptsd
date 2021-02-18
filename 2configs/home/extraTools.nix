{ config, lib, pkgs, ... }:

# Tools you probably would not add to an ISO image
let
  py3 = pkgs.python3.override {
    packageOverrides = self: super: rec {
      black_nbconvert = self.callPackage ../../5pkgs/black_nbconvert { };
      davphonebook = self.callPackage ../../5pkgs/davphonebook { };
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
      pandas
      pdfminer
      pillow
      requests
      selenium
    ]
  );
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };
  unstable = import <nixpkgs-unstable> { };
in
{
  #imports = [
  #  <ptsd/2configs/home/irssi.nix>
  #  <ptsd/2configs/home/mbsync.nix>
  #];

  home.packages = with pkgs; let
    mywine = wine.override { wineBuild = "wine32"; wineRelease = "staging"; };
  in
  [
    #(
    #  ffmpeg-full.override {
    #    nonfreeLicensing = true;
    #    fdkaacExtlib = true;
    #    ffplayProgram = false;
    #    ffprobeProgram = false;
    #    qtFaststartProgram = false;
    #  }
    #)
    ffmpeg-full
    sshfs
    (pdftk.override { jre = openjdk11; })
    #mywine
    #(winetricks.override { wine = mywine; })
    #slack-dark
    #jetbrains.idea-ultimate
    #jetbrains.goland
    #jetbrains.pycharm-professional
    vscodium
    sqlitebrowser
    #filezilla
    libreoffice-fresh
    inkscape
    gimp
    #tor-browser-bundle-bin
    xournalpp
    #calibre
    (xmind.override { jre = openjdk11; })
    transmission-gtk
    sylpheed
    #zoom-us
    pulseeffects-pw
    xorg.xev
    xorg.xhost
    gnome3.file-roller
    #nerdworks-motivation
    keepassxc
    xcalib
    # TODO: rm when https://github.com/NixOS/nixpkgs/pull/108976 is merged
    (portfolio.overrideAttrs (old: rec {
      version = "0.50.0";
      src = fetchurl {
        url = "https://github.com/buchen/portfolio/releases/download/${version}/PortfolioPerformance-${version}-linux.gtk.x86_64.tar.gz";
        sha256 = "1jq4if5hx3fwag1dz38sj87av2na1kv4c36hai1gyz9w5qhjv7j8";
      };
    }))
    #woeusb
    betaflight-configurator
    #dbeaver
    drone-cli
    #openshift
    #minishift
    cachix
    pyenv
    docker_compose
    #nvi # needed for virsh # broken in 20.03 as of 2020-04-03
    dnsmasq
    wireshark-qt
    freerdp
    sqlitebrowser
    #asciinema
    gnumake
    qrencode
    #nix-deploy
    #hcloud
    dep2nix
    #xca
    gcolor3
    vlc
    syncthing
    imagemagick
    youtube-dl
    spotify
    vlc
    (drawio.overrideAttrs (oldAttrs: {
      # fix wrong file handling in default desktop file for file manager integration
      patchPhase = ''
        substituteInPlace usr/share/applications/drawio.desktop \
          --replace 'drawio %U' 'drawio %f'
      '';
    }))
    geckodriver
    smbclient
    mu-repo
    file-rename
    #sublime3
    teamviewer
    #discord
    #mediathekview
    rclone
    tdesktop
    obs-studio
    #gnome3.evolution
    #go
    #go-bindata
    #delve
    #gofumpt
    #bitwarden-cli
    nbconvert
    peek
    hidclient
    fava
    #AusweisApp2
    ffmpeg-normalize
    weatherbg
    shrinkpdf
    gitAndTools.hub
    py3.pkgs.davphonebook
    teams
    nix-tree
    #pssh
    screenkey
    v4l-utils
    hydra-check
    dfeet
    anki
    kakoune
    unstable.noisetorch # unstable has newer version than 20.09
    #sqlmap
    mumble
  ];

  home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
    rm -rf $HOME/.config/obs-studio/plugins
    mkdir -p $HOME/.config/obs-studio/plugins
    ln -sf ${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
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

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      company
      company-tabnine
      deadgrep
      dockerfile-mode
      evil
      evil-org
      go-mode
      magit
      neotree
      nix-mode
      org
      solarized-theme
      yaml-mode
    ];
  };

  # Link emacs config to well-known path
  home.file.".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink /home/enno/repos/ptsd/src/init.el;
}
