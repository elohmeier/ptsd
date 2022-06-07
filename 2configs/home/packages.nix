{ config, lib, pkgs, ... }:

with lib;
{
  home.packages = with pkgs; [

    alacritty
    bat
    btop
    exa
    fd
    fzf
    home-manager
    jless
    neovim
    nixpkgs-fmt
    ptsd-nnn
    ripgrep
    tig
    tmux
    watch
    zellij
    zellij

    (ptsd-python3.withPackages (
      pythonPackages: with pythonPackages; [

        # TODO: add packages working on darwin

      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
        authlib
        #beancount
        black
        holidays
        i3ipc
        jupyterlab
        lxml
        keyring
        nbconvert
        pandas
        pdfminer
        pillow
        requests
        selenium
        tabulate
        weasyprint
        beautifulsoup4
        pytest
        mypy
        isort
        #nobbofin
        sshtunnel
        mysql-connector
        boto3
        impacket
        pycrypto
        pylint
        pyxlsb
        psycopg2
        faker
        netifaces
        paramiko
      ]
    ))


  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [

    logseq
    ptsd-vscode
    (writers.writeBashBin "edit-hosts" ''set -e; cat /etc/hosts > /etc/hosts.edit; vim /etc/hosts.edit; mv /etc/hosts.edit /etc/hosts;'')
    #aliza # dicom viewer
    #art
    #calibre
    #cura
    #freecad
    asciinema
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    AusweisApp2
    awscli2
    bat
    bc
    bubblewrap
    cachix
    cifs-utils
    clang-tools
    dnsmasq
    exiftool
    fava
    file
    freerdp
    gen-secrets
    ghostscript
    gimp
    gnome3.file-roller
    gnupg
    go
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
    ncdu
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
    pass
    pdf2svg
    pdfconcat
    pdfduplex
    pdftk
    prusa-slicer
    ptsd-ffmpeg
    ptsd-nnn
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

  ];

}
