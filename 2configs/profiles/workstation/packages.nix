{ config, lib, pkgs, ... }: {

  environment.systemPackages = with pkgs; lib.mkIf (!config.ptsd.minimal) (hackertools ++ [
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
    #dbeaver
    #clinfo
    #mupdf
    #libsixel
    awscli2
    #gcolor3
    syncthing
    #geckodriver
    smbclient
    #mu-repo
    #file-rename
    #peek
    #hidclient
    #screenkey
    hydra-check
    #dfeet
    bc
    #bind
    #bridge-utils
    file
    #htop
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
    #lorri
    smartmontools
    gptfdisk
    parted
    usbutils
    #wirelesstools
    #wpa_supplicant
    #macchanger
    p7zip
    unrar
    #mosh
    mkpasswd
    netcat-gnu
    nwbackup-env
    nix-index
    #ptsdbootstrap
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
    freecad
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
    #teamviewer
    qrencode
    sshfs
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
    ptsd-py2env
    ptsd-py3env
    #docker_compose
    #kakoune
    go
    #python3Packages.graphtage
    #clang
    nix-prefetch-git
    #jetbrains.datagrip

    # *** kvm ***
    virtviewer
    virtmanager

    # *** media ***
    audacity
    ptsd-ffmpeg
    #mpv # via home-manager...
    imagemagickBig
    ghostscript
    #ffmpeg-normalize
    youtube-dl
    vlc
    #mediathekview
    obs-studio
    #v4l-utils
    wf-recorder
    #art
    exiftool
    espeak

    # *** office ***
    quirc # qr scanner
    #aliza # dicom viewer
    #google-drive-ocamlfuse
    gnome3.file-roller
    xournalpp
    #calibre
    transmission-gtk
    fava
    beancount
    #anki
    sylpheed
    #claws-mail
    keepassxc
    pdftk
    libreoffice-fresh
    inkscape
    gimp
    shrinkpdf
    element-desktop
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
    #tg
    #tdesktop
    pdfduplex
    pdf2svg

    (makeDesktopItem {
      name = "zathura";
      desktopName = "Zathura";
      exec = "${pkgs.zathura}/bin/zathura %f";
      mimeType = "application/pdf";
      type = "Application";
    })

    dbmate
    haskellPackages.postgrest
    shfmt

    # *** infosec ***
    # see also https://jjjollyjim.github.io/arewehackersyet/index.html

    # included via frix/hackertools

    # proxychains
    # sshuttle
    # ghidra-bin
    # rlwrap
    # hash-identifier
    # net-snmp
    # metasploit
    # postgresql # for msfdb
    # wpscan
    # john
    # gobuster
    # burpsuite-pro
    # hashcat
    # sqlmap
    # nbtscanner
    # wireshark-qt
    # pwndbg
    # # TODO: add wordlists from https://github.com/NixOS/nixpkgs/pull/104712
    # nikto
    # py2env
    # (writers.writePython2Bin "kirbi2hashcat"
    #   {
    #     libraries = [ python2Packages.pyasn1 ];
    #     flakeIgnore = [ "E501" "W503" ]; # line length (black)
    #   } ../4scripts/kirbi2hashcat.py)

  ] ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-linux") [

    # long tensorflow build...
    photoprism

    # *** fpv ***
    betaflight-configurator

    #discord
    spotify
    easyeffects

    # *** games ***
    # wine # 32-bit only
    wineWowPackages.stable # 32-bit & 64-bit
    winetricks
    #ppsspp # TODO: wait for https://github.com/NixOS/nixpkgs/pull/124162
    #epsxe
    #mupen64plus

    portfolio
    teams
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

    wkhtmltopdf-qt4
  ]);

  programs.noisetorch.enable = !config.ptsd.minimal;
}
