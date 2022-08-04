{ config, lib, pkgs, ... }:

with lib;
{
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = 1;
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/repos/password-store";
  };
  home.file.".lq/config.edn".text = "{:default-options {:graph \"logseq\"}}";
  home.file.".password-store".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/password-store";

  home.packages = with pkgs; [
    bat
    btop
    copy-secrets
    entr
    exa
    exiftool
    fd
    fzf
    gh
    google-cloud-sdk
    hcloud
    home-manager
    httpserve
    hydra-check
    imagemagickBig
    jless
    jq
    libfaketime
    logseq-query
    macos-fix-filefoldernames
    ncdu
    neovim
    nix-tree
    nixos-generators
    nixpkgs-fmt
    nixpkgs-fmt
    nmap
    node2nix
    nodePackages.prettier
    pass
    poppler_utils
    ptsd-nnn
    pwgen
    qrencode
    rar
    ripgrep
    tabula-java
    tig
    tmux
    unzip
    watch
    wrk
    zathura
    zellij

    (ptsd-python3.withPackages (
      pythonPackages: with pythonPackages;
      [
        XlsxWriter
        black
        faker
        hocr-tools
        holidays
        ipython
        isort
        lxml
        matplotlib
        mypy
        pandas
        psycopg2
        pycrypto
        pyjwt
        pylint
        pytest
        pyxlsb
        requests
        scikit-learn
        sqlalchemy
        tabulate
      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
        authlib
        beautifulsoup4
        boto3
        i3ipc
        impacket
        jupyterlab
        keyring
        mysql-connector
        nbconvert
        netifaces
        paramiko
        pdfminer
        pillow
        pyodbc
        selenium
        sshtunnel
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
    (pdftk.override { jre = openjdk11; })
    (writers.writeBashBin "edit-hosts" ''set -e; cat /etc/hosts > /etc/hosts.edit; vim /etc/hosts.edit; mv /etc/hosts.edit /etc/hosts;'')
    AusweisApp2
    apacheHttpd
    asciinema
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    awscli2
    bc
    bubblewrap
    cachix
    cifs-utils
    clang-tools
    dnsmasq
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
    home-assistant-cli
    httpie
    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large
    iftop
    inkscape
    iotop
    keepassxc
    killall
    lftp
    libreoffice-fresh
    mkpasswd
    mumble
    nbconvert
    netcat-gnu
    nix-index
    nix-prefetch-git
    nix-top
    nwvpn-qr
    openssl
    openvpn
    p7zip
    paperkey
    parted
    pdf2svg
    pdfconcat
    pdfduplex
    pgmodeler
    ptsd-ffmpeg
    ptsd-vscode
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
    sxiv
    sylpheed
    syncthing
    syncthing-device-id
    tmuxinator
    transmission-gtk
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
    #wineWowPackages.stable # 32-bit & 64-bit
    #winetricks
    #wkhtmltopdf-qt4
    betaflight-configurator
    easyeffects
    logseq
    photoprism # long tensorflow build on aarch64...
    portfolio
    prusa-slicer
    signal-desktop
    spotify
  ];
}
