p@{ config, lib, pkgs, ... }:

with lib;
{
  home.sessionVariables = {
    BAT_THEME = "ansi";
    NIXPKGS_ALLOW_UNFREE = 1;
    NNN_PLUG = "p:preview-tui;f:fzcd;z:autojump;u:ulp";
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/repos/password-store";
    PASSAGE_AGE = "${pkgs.rage}/bin/rage";
    PASSAGE_DIR = "${config.home.homeDirectory}/repos/passage-store";
  };
  home.file.".lq/config.edn".text = "{:default-options {:graph \"logseq\"}}";
  home.file.".password-store".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/password-store";
  home.file.".passage".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/passage-store";

  home.file.".config/nnn/plugins".source = if (builtins.hasAttr "nixosConfig" p) then ../../4scripts/nnn-plugins else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/4scripts/nnn-plugins";

  home.packages = with pkgs; [
    # (writeShellScriptBin "paperless-id" (builtins.readFile ../../4scripts/paperless-id))
    # (writeShellScriptBin "transcribe-video" (builtins.readFile ../../4scripts/transcribe-video))
    # cargo
    # mpv
    # nodePackages.svelte-language-server
    # nodePackages.typescript-language-server
    # rmlint
    # rustc
    # zathura
    (passage.override { age = rage; })
    (pdftk.override { jre = openjdk17; })
    (tesseract5.override { enableLanguages = [ "deu" "eng" ]; })
    age-plugin-yubikey
    # attic-server
    bat
    btop
    bun
    bundix
    copy-secrets
    deadnix
    diceware
    difftastic
    dive
    entr
    eternal-terminal
    exiftool
    eza
    fastlane
    fava
    fd
    ffmpeg
    fzf-no-fish
    gen-secrets
    gh
    ghostscript
    go
    go-jsonnet
    gojsontoyaml
    gomuks
    google-cloud-sdk
    hcloud
    helix
    home-manager
    httpserve
    hydra-check
    hyperfine
    imagemagickBig
    iperf2
    jaq
    jc
    jdk
    jdt-language-server
    jless
    jq
    jsonnet-bundler
    jsonnet-language-server
    kubectl
    lazygit
    libfaketime
    libxml2 # xmllint
    logseq-query
    macos-fix-filefoldernames
    miller
    minikube
    minio-client
    mkpasswd
    mupdf
    ncdu_1
    nix-index
    nix-prefetch-git
    nix-top
    nix-tree
    nixd
    nixos-generators
    nixpkgs-fmt
    nmap
    node2nix
    nodePackages.yarn
    nodejs-18_x
    nushell
    ollama
    p7zip
    pass
    plantuml
    poetry
    poppler_utils
    prettier-with-plugins
    ptsd-nnn
    pwgen
    qpdf
    qrencode
    quirc # qr scanner
    rage
    rclone
    remarshal
    ripgrep
    ruff
    rustup
    shellcheck
    shfmt
    shrinkpdf
    skopeo
    statix
    tabula-java
    tanka
    taskjuggler
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
    yq
    yt-dlp
    yubikey-manager
    zellij

    # (ptsd-python3.withPackages (
    ((python3.override {
      packageOverrides = self: super: {
        django = super.django.overridePythonAttrs (old: { doCheck = false; });
      };
    }).withPackages (
      pythonPackages: with pythonPackages;
      [
        #     # sqlacodegen
        # google-cloud-vision
        ((ocrmypdf.override { tesseract = (tesseract5.override { enableLanguages = [ "deu" "eng" ]; }); }).overridePythonAttrs (_: { doCheck = false; }))
        XlsxWriter
        #     alembic
        #     # langchain
        authlib
        #     beancount
        #     soupsieve
        #     beautifulsoup4
        black
        #     boto3
        #     dataclasses-json
        #     debugpy
        #     djhtml
        #     faker
        #     fastapi
        #     flask
        #     guidance
        #     hdbscan
        #     hocr-tools
        #     holidays
        #     icalendar
        #     impacket
        #     ipykernel
        #     ipython
        isort
        jupyterlab
        #     keras
        #     keyring
        #     lark
        #     lxml
        # matplotlib
        #     mypy
        #     mysql-connector
        #     (pygrok.overrideAttrs (_: {
        #       meta.platforms = lib.platforms.unix;
        #     }))
        #     netifaces
        #     nltk
        #     openai
        # opencv4
        #     openpyxl
        pandas
        #     paramiko
        #     pdfminer-six
        #     pikepdf
        pillow
        psycopg2
        #     pudb
        #     pycrypto
        #     pyjwt
        #     pylint
        pymupdf
        #     pynvim
        #     pypdf2
        pytest
        pyxlsb
        requests
        # sqlalchemy
        #     sshtunnel
        #     tabulate
        #     # tasmota-decode-config
        #     tenacity
        #     # tensorflow
        #     tkinter
        #     # umap-learn
        #     uvicorn
        #     weasyprint
      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "aarch64-darwin" ]) [
        #     accelerate
        #     # bertopic
        #     # flair
        #     # mlxtend
        #     nurl
        #     # presidio-analyzer
        #     # presidio-anonymizer
        #     pysbd
        #     scikit-learn
        #     sentence-transformers
        #     spacy
        #     spacy_models.de_core_news_md
        #     spacy_models.en_core_web_lg
        #     stanza
        #     thefuzz
        #     tiktoken # slow build / unneeded on most machines
      ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) [
        # i3ipc
        # pyodbc
        # selenium
      ]
    ))
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "aarch64-darwin" ]) [
    age-plugin-se
    binutils
    # kubectl-minio
    llvmPackages.lldb
    # openai-whisper-cpp
    # qemu
    rar
    # subler-bin
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
    # AusweisApp2
    apacheHttpd
    asciinema
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    # awscli2
    bc
    # bubblewrap
    cifs-utils
    # clang-tools
    # dnsmasq
    esphome
    esptool
    file
    freerdp
    gimp
    gnupg
    # go-sqlcmd
    gptfdisk
    home-assistant-cli
    hunspellDicts.de-de
    hunspellDicts.en-gb-large
    hunspellDicts.en-us-large
    # iftop
    # imapsync
    inkscape
    # iotop
    keepassxc
    # killall
    # lftp
    libreoffice-fresh
    # minicom
    # mumble
    netcat-gnu
    openssl
    openvpn
    paperkey
    parted
    pdf2svg
    # pdfduplex
    # pgmodeler
    ripmime
    # samba
    # screen
    # smartmontools
    # sqlfluff
    sqlitebrowser
    # sshfs
    sxiv
    # sylpheed
    syncthing
    syncthing-device-id
    # transmission-gtk
    unrar
    usbutils
    # vlc
    # wf-recorder
    xdg-utils
    zig
    # xfsprogs.bin
    # xournalpp
  ] ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" ]) [
    betaflight-configurator
    cabextract
    easyeffects
    logseq
    portfolio
    prusa-slicer
    signal-desktop
    spotify
    # wineWowPackages.unstable
  ];
}

