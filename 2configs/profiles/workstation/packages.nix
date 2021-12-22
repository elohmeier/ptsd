{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    hcloud
    tmuxinator
    sqlfluff
    dbeaver
    clinfo
    discord
    mupdf
    libsixel
    exa
    awscli2
    gcolor3
    syncthing
    geckodriver
    smbclient
    mu-repo
    file-rename
    peek
    hidclient
    screenkey
    hydra-check
    dfeet
    fishPlugins.fzf-fish
    fishPlugins.done
    fzf
    zoxide
    bc
    bind
    bridge-utils
    file
    htop
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
    gnumake
    #(pass.withExtensions (ext: [ ext.pass-import ]))
    pass
    openssl
    lorri
    smartmontools
    gptfdisk
    parted
    usbutils
    wirelesstools
    wpa_supplicant
    macchanger
    p7zip
    unrar
    mosh
    mkpasswd
    netcat-gnu
    nwbackup-env
    nix-index
    ptsdbootstrap
    ptsd-nnn
    bat

    bubblewrap
    nsjail


    # *** 3dprinting ***
    prusa-slicer
    # todo: add
    # https://github.com/triplus/PieMenu
    # https://github.com/triplus/Glass
    freecad
    cura
    prusa-slicer
    f3d

    # *** admin ***
    tigervnc
    ethtool
    gparted
    git
    gnupg
    # TODO: broken lxqt-policykit, replace/fix
    #lxqt.lxqt-policykit # provides a default authentification client for policykit
    xdg_utils
    gen-secrets
    syncthing-device-id
    nwvpn-qr
    paperkey
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
    gnumake
    #nix-deploy
    #hcloud
    dep2nix
    #dbeaver
    drone-cli
    #openshift
    #minishift
    cachix
    ptsd-py2env
    ptsd-py3env
    #docker_compose
    #kakoune
    go
    python3Packages.graphtage
    clang
    nix-prefetch-git
    jetbrains.datagrip

    # *** fpv ***
    betaflight-configurator

    # *** games ***
    epsxe
    mupen64plus
    # wine # 32-bit only
    wineWowPackages.stable # 32-bit & 64-bit
    winetricks
    #ppsspp # TODO: wait for https://github.com/NixOS/nixpkgs/pull/124162

    # *** kvm ***
    virtviewer
    virtmanager

    # *** media ***
    audacity
    ptsd-ffmpeg
    #mpv # via home-manager...
    imagemagickBig
    ghostscript
    ffmpeg-normalize
    youtube-dl
    spotify
    vlc
    #mediathekview
    obs-studio
    v4l-utils
    easyeffects
    wf-recorder
    art
    exiftool
    espeak


    # *** office ***
    quirc # qr scanner
    aliza
    google-drive-ocamlfuse
    gnome3.file-roller
    xournalpp
    #calibre
    transmission-gtk
    fava
    beancount
    anki
    sylpheed
    claws-mail
    #nerdworks-motivation
    keepassxc
    (pdftk.override { jre = openjdk11; })
    libreoffice-fresh
    inkscape
    gimp
    portfolio
    shrinkpdf
    ptsd-python3.pkgs.davphonebook
    teams
    element-desktop
    signal-desktop
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large
    mumble
    noisetorch
    tg
    tdesktop
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
    pdfduplex
    pdf2svg

    zathura-single
    (makeDesktopItem {
      name = "zathura";
      desktopName = "Zathura";
      exec = "${pkgs.zathura}/bin/zathura %f";
      mimeType = "application/pdf";
      type = "Application";
    })

    wkhtmltopdf-qt4

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

  ];
}
