{ config, lib, pkgs, ... }:

with lib;
{
  home.sessionVariables = {
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/repos/password-store";
  };

  home.packages = with pkgs; [

    bat
    btop
    entr
    exa
    exiftool
    fd
    fzf
    home-manager
    httpserve
    jless
    logseq-query
    macos-fix-filefoldernames
    ncdu
    neovim
    nixos-generators
    nixpkgs-fmt
    node2nix
    pass
    ptsd-nnn
    ripgrep
    tabula-java
    tig
    tmux
    watch
    zathura
    zellij
    zellij

    (ptsd-python3.withPackages (
      pythonPackages: with pythonPackages; [

        # TODO: add packages working on darwin

      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
        #beancount
        #nobbofin
        XlsxWriter
        authlib
        beautifulsoup4
        black
        boto3
        faker
        holidays
        i3ipc
        impacket
        isort
        jupyterlab
        keyring
        lxml
        mypy
        mysql-connector
        nbconvert
        netifaces
        pandas
        paramiko
        pdfminer
        pillow
        psycopg2
        pycrypto
        pylint
        pyodbc
        pytest
        pyxlsb
        requests
        selenium
        sqlalchemy
        sshtunnel
        tabulate
        weasyprint
      ]
    ))
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "aarch64-darwin" ]) [

    ffmpeg
    logseq-bin
    subler-bin

  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [

    #aliza # dicom viewer
    #art
    #calibre
    #cura
    #freecad
    (writers.writeBashBin "edit-hosts" ''set -e; cat /etc/hosts > /etc/hosts.edit; vim /etc/hosts.edit; mv /etc/hosts.edit /etc/hosts;'')
    AusweisApp2
    asciinema
    aspell
    pgmodeler
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    awscli2
    bat
    bc
    bubblewrap
    cachix
    cifs-utils
    clang-tools
    dnsmasq
    fava
    file
    freerdp
    gen-secrets
    ghostscript
    gimp
    gnome3.file-roller
    gnupg
    go
    go-sqlcmd
    gomuks
    gptfdisk
    hash-slinger # tlsa
    hcloud
    home-assistant-cli
    httpie
    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large
    hydra-check
    iftop
    imagemagickBig
    inkscape
    iotop
    jq
    keepassxc
    killall
    lftp
    libfaketime
    libreoffice-fresh
    mkpasswd
    mumble
    nbconvert
    netcat-gnu
    nix-index
    nix-prefetch-git
    nix-top
    nix-tree
    nixpkgs-fmt
    nixpkgs-fmt
    nmap
    nodePackages.prettier
    nwvpn-qr
    openssl
    openvpn
    p7zip
    paperkey
    parted
    pdf2svg
    pdfconcat
    pdfduplex
    (pdftk.override { jre = openjdk11; })
    ptsd-ffmpeg
    ptsd-nnn
    ptsd-vscode
    pwgen
    qrencode
    quirc # qr scanner
    rclone
    ripmime
    rmlint
    samba
    screen
    shellcheck
    shfmt
    shrinkpdf
    smartmontools
    sqlfluff
    sqlitebrowser
    sshfs
    sylpheed
    syncthing
    syncthing-device-id
    tig
    tmuxinator
    transmission-gtk
    unrar
    unzip
    usbutils
    vlc
    wf-recorder
    wget
    wireshark-qt
    xdg_utils
    xfsprogs.bin
    xournalpp
    yt-dlp

  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" ]) [

    #winetricks
    #wineWowPackages.stable # 32-bit & 64-bit
    #wkhtmltopdf-qt4
    betaflight-configurator
    easyeffects
    photoprism # long tensorflow build on aarch64...
    portfolio
    signal-desktop
    spotify
    logseq
    prusa-slicer

  ];

}
