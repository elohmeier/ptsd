p@{ config, lib, pkgs, ... }:

with lib;
{
  home.sessionVariables = {
    BAT_THEME = "GitHub";
    NIXPKGS_ALLOW_UNFREE = 1;
    NNN_PLUG = "p:preview-tui;f:fzcd;z:autojump;u:ulp";
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/repos/password-store";
  };
  home.file.".lq/config.edn".text = "{:default-options {:graph \"logseq\"}}";
  home.file.".password-store".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/password-store";

  home.file.".config/nnn/plugins".source = if (builtins.hasAttr "nixosConfig" p) then ../../4scripts/nnn-plugins else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/4scripts/nnn-plugins";

  home.packages = with pkgs; [
    (pdftk.override { jre = openjdk17; })
    bat
    btop
    (writeShellScriptBin "paperless-id" (builtins.readFile ../../4scripts/paperless-id))
    (writeShellScriptBin "transcribe-video" (builtins.readFile ../../4scripts/transcribe-video))
    copy-secrets
    entr
    exa
    exiftool
    fd
    fzf
    gen-secrets
    gh
    gomuks
    google-cloud-sdk
    hcloud
    helix
    home-manager
    httpie
    httpserve
    hydra-check
    imagemagickBig
    iperf2
    jaq
    jless
    libfaketime
    logseq-query
    macos-fix-filefoldernames
    mpv
    ncdu_1
    nix-tree
    nixos-generators
    nixpkgs-fmt
    nixpkgs-fmt
    nmap
    node2nix
    nodePackages.prettier
    p7zip
    pass
    poppler_utils
    ptsd-nnn
    pwgen
    qrencode
    rclone
    ripgrep
    rmlint
    shfmt
    shrinkpdf
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
        # sqlacodegen
        XlsxWriter
        black
        faker
        hocr-tools
        holidays
        ipykernel
        ipython
        isort
        jupyterlab
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
        tasmota-decode-config
      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
        authlib
        beancount
        beautifulsoup4
        boto3
        flask
        i3ipc
        impacket
        keyring
        lark
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
    qemu
    rar
    subler-bin
    whisper-cpp
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
    # hash-slinger # tlsa
    AusweisApp2
    apacheHttpd
    asciinema
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    # platformio
    awscli2
    bc
    bubblewrap
    cachix
    cifs-utils
    clang-tools
    dnsmasq
    esptool
    fava
    file
    freerdp
    ghostscript
    gimp
    gnupg
    go
    go-sqlcmd
    gptfdisk
    home-assistant-cli
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
    minicom
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
    paperkey
    parted
    pdf2svg
    pdfduplex
    pgmodeler
    ptsd-ffmpeg
    quirc # qr scanner
    ripmime
    samba
    screen
    shellcheck
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
    uncrustify
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
