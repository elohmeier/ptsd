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
    (tesseract5.override { enableLanguages = [ "deu" "eng" ]; })
    (writeShellScriptBin "paperless-id" (builtins.readFile ../../4scripts/paperless-id))
    (writeShellScriptBin "transcribe-video" (builtins.readFile ../../4scripts/transcribe-video))
    bat
    btop
    cargo
    copy-secrets
    deadnix
    difftastic
    entr
    eternal-terminal
    exa
    exiftool
    fava
    fd
    ffmpeg
    fzf-no-fish
    gen-secrets
    gh
    gomuks
    google-cloud-sdk
    hcloud
    helix
    home-manager
    httpserve
    hydra-check
    imagemagickBig
    iperf2
    jaq
    jc
    jless
    lazygit
    libfaketime
    logseq-query
    macos-fix-filefoldernames
    miller
    mkpasswd
    mpv
    ncdu_1
    nix-index
    nix-prefetch-git
    nix-top
    nix-tree
    nixos-generators
    nixpkgs-fmt
    nmap
    node2nix
    nodePackages.svelte-language-server
    nodePackages.typescript-language-server
    nodejs-18_x
    ocrmypdf
    p7zip
    pass
    poppler_utils
    prettier-with-plugins
    ptsd-nnn
    pwgen
    qpdf
    qrencode
    quirc # qr scanner
    rclone
    remarshal
    ripgrep
    rmlint
    rustc
    shellcheck
    shfmt
    shrinkpdf
    statix
    tabula-java
    tig
    tmux
    tmuxinator
    treefmt
    typescript
    uncrustify
    unzip
    viu # terminal image viewer
    vivid
    watch
    websocat
    wget
    wireguard-tools
    wrk
    xh
    xz
    yt-dlp
    zathura
    zellij

    (ptsd-python3.withPackages (
      pythonPackages: with pythonPackages;
      [
        # sqlacodegen
        XlsxWriter
        alembic
        authlib
        beancount
        beautifulsoup4
        black
        boto3
        dataclasses-json
        djhtml
        faker
        fastapi
        flask
        hocr-tools
        holidays
        impacket
        ipykernel
        ipython
        isort
        jupyterlab
        keras
        keyring
        langchain
        lark
        lxml
        umap-learn
        hdbscan
        matplotlib
        mypy
        mysql-connector
        nbconvert
        netifaces
        nltk
        openai
        openpyxl
        pandas
        paramiko
        pdfminer-six
        pillow
        psycopg2
        pycrypto
        pyjwt
        pylint
        pypdf2
        pytest
        pyxlsb
        requests
        sqlalchemy
        sshtunnel
        tabulate
        tasmota-decode-config
        tenacity
        tensorflow
        uvicorn
        weasyprint
      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "aarch64-darwin" ]) [
        scikit-learn
        sentence-transformers
        jupyter_ascending
        tiktoken # slow build / unneeded on most machines
      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
        i3ipc
        pyodbc
        selenium
      ]
    ))
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "aarch64-darwin" ]) [
    iterm2
    logseq-bin
    openai-whisper-cpp
    qemu
    rar
    subler-bin
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
    # aliza # dicom viewer
    # art
    # calibre
    # cura
    # freecad
    # gnome3.file-roller
    # hash-slinger # tlsa
    # pdfconcat # fixme
    # platformio
    # ptsd-vscode
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
    esphome
    esptool
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
    mumble
    nbconvert
    netcat-gnu
    nwvpn-qr
    openssl
    openvpn
    paperkey
    parted
    pdf2svg
    pdfduplex
    pgmodeler
    ripmime
    samba
    screen
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
    xdg-utils
    xfsprogs.bin
    xournalpp
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" ]) [
    betaflight-configurator
    cabextract
    easyeffects
    logseq
    portfolio
    prusa-slicer
    signal-desktop
    spotify
    wineWowPackages.unstable
  ];
}
