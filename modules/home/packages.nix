p@{ config, lib, pkgs, ... }:

with lib;

let
  tesseract = (pkgs.tesseract5.override { enableLanguages = [ "deu" "eng" ]; });
in
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
    # attic-server
    # cargo
    # hatch
    # moreutils
    # mpv
    # nodePackages.svelte-language-server
    # nodePackages.typescript-language-server
    zstd.bin
    # rmlint
    # rustc
    # zathura
    ptsd-node-packages.prettier
    (pdftk.override { jre = openjdk17; })
    nurl
    gnumake
    hl
    go
    # nixd
    nodejs_latest
    djlint
    aider
    ripgrep
    zig
    age
    nix-init
    nix-melt
    age-plugin-yubikey
    h-move-repo
    azure-cli
    aerc
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
    foreman
    fzf-no-fish
    gh
    ghostscript
    gitu
    gnused
    go-jsonnet
    gojsontoyaml
    gomuks
    google-cloud-sdk
    graphviz
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
    kubernetes-helm
    lazygit
    libfaketime
    libxml2 # xmllint
    mermaid-cli
    miller
    minikube
    minio-client
    mupdf
    ncdu_1
    nil
    nix-prefetch-git
    nix-prefetch-github
    nix-top
    nix-tree
    nixos-generators
    nixpkgs-fmt
    nmap
    node2nix
    nodePackages.pnpm
    nodePackages.yarn
    nushell
    p7zip
    pass
    passage
    plantuml
    poetry
    poppler_utils
    pre-commit
    process-compose
    ptsd-nnn
    pwgen
    qpdf
    qrencode
    quirc # qr scanner
    rclone
    remarshal
    reveal-md
    ripgrep
    ruff
    rustup
    shellcheck
    shfmt
    shrinkpdf
    skopeo
    sops
    ssh-to-age
    statix
    tabula-java
    tanka
    taskjuggler
    tesseract
    texlive.combined.scheme-context
    tmux
    tmuxinator
    treefmt
    typescript
    uncrustify
    unzip
    visidata
    viu # terminal image viewer
    vivid
    wasm-pack
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
    zig

    # (ptsd-python3.withPackages (
    ((python3.override {
      packageOverrides = self: super: {
        django = super.django.overridePythonAttrs (old: { doCheck = false; });
        accelerate = super.accelerate.overridePythonAttrs (_: { doCheck = pkgs.stdenv.isLinux; });
        torch = if pkgs.stdenv.isDarwin then super.torch-bin else super.torch;
        torchvision = if pkgs.stdenv.isDarwin then super.torchvision-bin else super.torchvision;
      };
    }).withPackages (
      pythonPackages: with pythonPackages;
      [
        # (pygrok.overrideAttrs (_: { meta.platforms = lib.platforms.unix; }))
        # accelerate
        # alembic
        # beancount
        # beautifulsoup4
        # boto3
        # dataclasses-json
        # debugpy
        # diffusers
        # djhtml
        # faker
        # fastapi
        # flask
        # google-cloud-vision
        # guidance
        # hdbscan
        # hocr-tools
        # holidays
        # icalendar
        # impacket
        # ipykernel
        # ipython
        # keras
        # keyring
        # langchain
        # lark
        # lxml
        # matplotlib
        # mypy
        # mysql-connector
        # netifaces
        # nltk
        # openai
        # opencv4
        # openpyxl
        # paramiko
        # pdfminer-six
        # pikepdf
        # pudb
        # pycrypto
        # pyjsparser
        # pyjwt
        # pylint
        # pynvim
        # pypdf2
        # soupsieve
        # sqlacodegen
        # sqlalchemy
        # sqlalchemy
        # sshtunnel
        # tabulate
        # tasmota-decode-config
        # tenacity
        # tensorflow
        # tkinter
        # torch
        # torchvision
        # transformers
        # umap-learn
        # uvicorn
        # weasyprint
        ((ocrmypdf.override { tesseract = tesseract; }).overridePythonAttrs (_: { doCheck = false; }))
        XlsxWriter
        authlib
        beautifulsoup4
        black
        datasette
        httpx
        huggingface-hub
        ipywidgets
        isort
        jupyterlab
        llm
        pandas
        pillow
        psycopg2
        pymupdf
        pytest
        pyxlsb
        requests
        sqlite-utils
        structlog
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
    # age-plugin-se
    # binutils
    logseq-query
    ollama_unstable
    llama-cpp_unstable
    macos-fix-filefoldernames
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
    mkpasswd
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
    screen
    # go-sqlcmd
    #go-sqlcmd
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
    #pdfduplex
    pgmodeler
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
    #portfolio
    prusa-slicer
    signal-desktop
    spotify
    # wineWowPackages.unstable
  ];
}
