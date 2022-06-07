{ config, lib, pkgs, ... }: {

  environment.systemPackages = with pkgs; lib.mkIf (!config.ptsd.minimal) ([
    zellij
    httpie
    logseq
    ptsd-vscode
    (writeShellScriptBin "activate-da-home-again" ''
      ${config.home-manager.users.mainUser.home.activationPackage}/activate
    '')
    xfsprogs.bin
    jless
    ripmime
    AusweisApp2
    nodejs # for copilot.vim
    #pkgsCross.avr.buildPackages.gcc # avr-gcc
    #arduino
    #avrdude

    pdfconcat

    #wtype

    whois
    nix-top

    hash-slinger # tlsa
    hcloud
    tmuxinator
    sqlfluff
    #mupdf
    #libsixel
    awscli2
    #gcolor3
    syncthing
    #geckodriver
    samba
    #peek
    #hidclient
    #screenkey
    hydra-check
    #dfeet
    bc
    file
    iftop
    iotop
    jq
    killall
    libfaketime
    ncdu
    nmap
    pwgen
    rmlint
    screen
    tig
    unzip
    wget
    shellcheck
    nixpkgs-fmt
    #(pass.withExtensions (ext: [ ext.pass-import ]))
    pass
    openssl
    smartmontools
    gptfdisk
    parted
    usbutils
    p7zip
    unrar
    mkpasswd
    netcat-gnu
    nix-index
    ptsd-nnn
    bat

    bubblewrap
    #nsjail

    nodePackages.prettier
    #f2fs-tools


    # *** 3dprinting ***
    # todo: add
    # https://github.com/triplus/PieMenu
    # https://github.com/triplus/Glass
    #freecad
    #cura
    prusa-slicer
    #f3d

    # *** admin ***
    #tigervnc
    #ethtool
    #gparted
    git
    gnupg
    # TODO: broken lxqt-policykit, replace/fix
    #lxqt.lxqt-policykit # provides a default authentification client for policykit
    xdg_utils
    gen-secrets
    syncthing-device-id
    nwvpn-qr
    #paperkey
    nixpkgs-fmt
    #asciinema
    rclone
    qrencode
    sshfs
    clang-tools
    dnsmasq
    freerdp
    openvpn
    lftp
    cifs-utils
    home-assistant-cli

    (writers.writeBashBin "edit-hosts" ''
      set -e
      cat /etc/hosts > /etc/hosts.edit
      vim /etc/hosts.edit
      mv /etc/hosts.edit /etc/hosts
    '')

    # *** dev ***
    gitAndTools.hub
    nix-tree
    nbconvert
    sqlitebrowser
    #filezilla
    #gnumake
    #dep2nix
    #dbeaver
    #drone-cli
    #openshift
    #minishift
    cachix
    # ptsd-py2env
    ptsd-py3env
    #docker_compose
    #kakoune
    go
    #python3Packages.graphtage
    #clang
    nix-prefetch-git

    # *** kvm ***
    virt-viewer
    virtmanager

    # *** media ***
    audacity
    ptsd-ffmpeg
    #mpv # via home-manager...
    imagemagickBig
    ghostscript
    #ffmpeg-normalize
    yt-dlp
    vlc
    #mediathekview
    #obs-studio
    #v4l-utils
    wf-recorder
    #art
    exiftool
    #espeak

    # *** office ***
    quirc # qr scanner
    #aliza # dicom viewer
    gnome3.file-roller
    xournalpp
    #calibre
    transmission-gtk
    fava
    beancount
    sylpheed
    keepassxc
    pdftk
    libreoffice-fresh
    inkscape
    gimp
    shrinkpdf
    gomuks
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large
    mumble
    pdfduplex
    pdf2svg

    (makeDesktopItem {
      name = "zathura";
      desktopName = "Zathura";
      exec = "${pkgs.zathura}/bin/zathura %f";
      mimeTypes = [ "application/pdf" ];
      type = "Application";
    })

    #dbmate
    #haskellPackages.postgrest
    shfmt

    wireshark-qt

  ] ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-linux") [

    # long tensorflow build...
    #photoprism

    # *** fpv ***
    betaflight-configurator
    spotify
    easyeffects

    # *** games ***
    # wineWowPackages.stable # 32-bit & 64-bit
    # winetricks

    portfolio
    signal-desktop

    (drawio.overrideAttrs (oldAttrs: {
      # fix wrong file handling in default desktop file for file manager integration
      patchPhase = ''
        substituteInPlace usr/share/applications/drawio.desktop \
          --replace 'drawio %U' 'drawio %f'
      '';
    }))

    (writeTextFile {
      name = "drawio-mimetype";
      text = ''
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="application/vnd.jgraph.mxfile">
            <comment>draw.io Diagram</comment>
            <glob pattern="*.drawio" case-sensitive="true"/>
          </mime-type>
        </mime-info>
      '';
      destination = "/share/mime/packages/drawio.xml";
    })

    #wkhtmltopdf-qt4
  ]);
}
