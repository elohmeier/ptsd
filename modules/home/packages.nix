p@{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  tesseract = (
    pkgsUnstable.tesseract5.override {
      enableLanguages = [
        "deu"
        "eng"
      ];
    }
  );
in
{
  home.sessionVariables = {
    BAT_THEME = "ansi";
    NIXPKGS_ALLOW_UNFREE = 1;
    NNN_PLUG = "p:preview-tui;f:fzcd;z:autojump;u:ulp";
  };
  home.file.".lq/config.edn".text = "{:default-options {:graph \"logseq\"}}";

  home.file.".streamlit/config.toml".source =
    (pkgs.formats.toml { }).generate "streamlit-config.toml"
      { browser.gatherUsageStats = false; };

  home.file.".config/nnn/plugins".source =
    if (builtins.hasAttr "nixosConfig" p) then
      ../../4scripts/nnn-plugins
    else
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/4scripts/nnn-plugins";

  home.packages =
    with pkgs;
    [
      # (writeShellScriptBin "paperless-id" (builtins.readFile ../../4scripts/paperless-id))
      # (writeShellScriptBin "transcribe-video" (builtins.readFile ../../4scripts/transcribe-video))
      # attic-server
      # cargo
      # hatch
      # moreutils
      # mpv
      # nixd
      # nodePackages.svelte-language-server
      # nodePackages.typescript-language-server
      # rmlint
      # rustc
      realise-symlink
      # (pdftk.override { jre = openjdk17; })
      aerc
      pkgsMaster.uv
      pandoc
      age
      age-plugin-yubikey
      # awscli2
      # azure-cli
      bat
      btop
      bun
      # bundix
      deadnix
      diceware
      difftastic
      dive
      # pkgsMaster.aider-chat
      pkgsUnstable.aichat
      pkgsUnstable.tig
      djlint
      dust
      nbqa
      entr
      eternal-terminal
      exiftool
      eza
      fastlane
      fava
      fd
      ffmpeg
      foreman
      gh
      ghostscript
      gitu
      gnumake
      gnused
      go
      go-jsonnet
      gojsontoyaml
      # gomuks
      google-cloud-sdk
      graphviz
      hcloud
      helix
      hl
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
      libfaketime
      libxml2 # xmllint
      mermaid-cli
      miller
      # minikube
      minio-client
      mupdf
      ncdu_1
      nil
      nix-init
      nix-melt
      nix-prefetch-git
      nix-prefetch-github
      nix-top
      nix-tree
      nix-update
      nixfmt-rfc-style
      nixos-generators
      nmap
      node2nix
      pkgsMaster.nodePackages.pnpm
      pkgsMaster.nodePackages.yarn
      nodejs_latest
      nurl
      nushell
      p7zip
      plantuml
      # poetry
      poppler_utils
      pre-commit
      process-compose
      ptsd-nnn
      ptsd-node-packages.prettier
      ptsd-node-packages.readability-cli
      pwgen
      qpdf
      qrencode
      quirc # qr scanner
      rclone
      # remarshal
      # reveal-md
      ripgrep
      # ruff
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
      taplo
      taskjuggler
      tesseract
      texlive.combined.scheme-context
      tmux
      tmuxinator
      treefmt
      typescript
      # uncrustify
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
      # zig
      zstd.bin

      # (
      #   (pkgsUnstable.python312.override {
      #     packageOverrides = self: super: {
      #       llm-claude-3 = self.callPackage ../../packages/llm-claude-3 { };
      #     };
      #   }).withPackages
      #   (
      #     pythonPackages: with pythonPackages; [
      #       ((ocrmypdf.override { tesseract = tesseract; }).overridePythonAttrs (_: {
      #         doCheck = false;
      #       }))
      #       XlsxWriter
      #       authlib
      #       beautifulsoup4
      #       black
      #       datasette
      #       httpx
      #       huggingface-hub
      #       ipympl
      #       ipywidgets
      #       isort
      #       jupyterlab
      #       (llm.withPlugins ([ llm-claude-3 ]))
      #       pandas
      #       pillow
      #       psycopg2
      #       pymupdf
      #       pytest
      #       pyxlsb
      #       requests
      #       sqlite-utils
      #       structlog
      #     ]
      #   )
      # )
    ]
    ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "aarch64-darwin" ]) [
      # age-plugin-se
      # binutils
      # logseq-query
      (pkgs.wezterm.overrideAttrs (_: {
        patches = [
          # kitty delete key fix - https://github.com/wez/wezterm/pull/5025
          (pkgs.fetchpatch {
            url = "https://github.com/wez/wezterm/commit/855957ec82a28621b8287ac595ac6decd36149c1.patch";
            hash = "sha256-E7rRA9d2929dqfwfIKxIwPKit3EphFur5k6Y2p5UBkU=";
          })
        ];
      }))
      # pkgsUnstable.ollama
      # pkgsUnstable.llama-cpp
      macos-fix-filefoldernames
      # kubectl-minio
      llvmPackages.lldb
      # openai-whisper-cpp
      # qemu
      rar
      # subler-bin
    ]
    ++
      lib.optionals
        (elem pkgs.stdenv.hostPlatform.system [
          "x86_64-linux"
          "aarch64-linux"
        ])
        [
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
        ]
    ++ lib.optionals (elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" ]) [
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
