p@{ config, lib, pkgs, ... }:

with lib;
{
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = 1;
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/repos/password-store";
    NNN_PLUG = "p:preview-tui;f:fzcd;z:autojump";
  };
  home.file.".lq/config.edn".text = "{:default-options {:graph \"logseq\"}}";
  home.file.".password-store".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/password-store";

  home.file.".config/nnn/plugins".source = if (builtins.hasAttr "nixosConfig" p) then ../../4scripts/nnn-plugins else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/4scripts/nnn-plugins";

  home.packages = with pkgs; [
    (pdftk.override { jre = openjdk17; })
    bat
    btop
    copy-secrets
    entr
    exa
    exiftool
    fd
    fzf
    gh
    gomuks
    google-cloud-sdk
    hcloud
    home-manager
    httpserve
    hydra-check
    imagemagickBig
    jless
    jaq
    libfaketime
    logseq-query
    macos-fix-filefoldernames
    mpv
    ncdu
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
    ripgrep
    statix
    tabula-java
    tig
    tmux
    unzip
    viu # terminal image viewer
    watch
    websocat
    wireguard-tools
    wrk
    xz
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
        sqlacodegen
        sqlalchemy
        tabulate
        tasmota-decode-config
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
    iterm2
    logseq-bin
    rar
    subler-bin
    qemu
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
    # pdfconcat # fixme
    #aliza # dicom viewer
    #art
    #calibre
    #cura
    #freecad
    #gnome3.file-roller
    #ptsd-vscode
    (writers.writeBashBin "edit-hosts" ''set -e; cat /etc/hosts > /etc/hosts.edit; nano /etc/hosts.edit; mv /etc/hosts.edit /etc/hosts;'')
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
    gnupg
    go
    go-sqlcmd
    gptfdisk
    hash-slinger # tlsa
    home-assistant-cli
    httpie
    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large
    iftop
    imapsync
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
    pdfduplex
    pgmodeler
    ptsd-ffmpeg
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
    unrar
    usbutils
    vlc
    wf-recorder
    wget
    xdg-utils
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
