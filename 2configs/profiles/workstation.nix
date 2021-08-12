{ pkgs, ... }:

let
  term = rec {
    package = pkgs.foot;
    binary = "${pkgs.foot}/bin/footclient"; # requires foot-server.service
    exec = prog: dir: "${binary}${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
    execFloating = prog: dir: "${binary} --app-id=term.floating${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
  };
in
{
  imports = [
    ../users/enno.nix
  ];

  environment.variables = {
    GOPATH = "/home/enno/go";
  };

  environment.systemPackages = with pkgs; [
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
    sqlitebrowser
    gnumake
    #nix-deploy
    #hcloud
    dep2nix
    #dbeaver
    drone-cli
    #openshift
    #minishift
    cachix
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
    (winetricks.override {
      wine = wineWowPackages.stable;
    })
    #ppsspp # TODO: wait for https://github.com/NixOS/nixpkgs/pull/124162

    # *** kvm ***
    virtviewer
    virtmanager

    # *** media ***
    audacity
    ptsd-ffmpeg
    mpv
    imagemagick
    ffmpeg-normalize
    youtube-dl
    spotify
    vlc
    #mediathekview
    obs-studio
    v4l-utils
    pulseeffects-pw
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
    #zoom-us
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
    zoom-us
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

  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;


  virtualisation.spiceUSBRedirection.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  programs.steam.enable = true;


  nixpkgs.config = {
    permittedInsecurePackages = [
      "openssl-1.0.2u" # epsxe
    ];
  };


  home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
    {
      imports = [
        ../home/chromium.nix
        ../home/firefox.nix
        ../home/fish.nix
        ../home/gpg.nix
        ../home/neovim.nix
        ../home/tmux.nix
        ../home/vscodium.nix
      ];

      programs.zathura = {
        enable = true;
        extraConfig =
          let
            cmd = term.execFloating "${pkgs.file-renamer} \"%\"" "";
          in
          ''
            map <C-o> exec '${cmd}'
          '';
      };

      ptsd.pcmanfm = {
        enable = true;
        term = term.binary;

        actions = {
          pdfconcat = {
            title = "Concat PDF files";
            title_de = "PDF-Dateien aneinanderhängen";
            mimetypes = [ "application/pdf" ];
            cmd = "${pkgs.alacritty}/bin/alacritty --hold -e ${pkgs.pdfconcat} %F";
            # #"${script} %F";
          };

          pdfduplex = {
            title = "Convert A & B PDF to Duplex-PDF";
            title_de = "Konvertiere A & B PDF zu Duplex-PDF";
            mimetypes = [ "application/pdf" ];
            cmd = "${pkgs.pdfduplex}/bin/pdfduplex %F";
            selectionCount = 2;
          };
        };

        thumbnailers = {
          imagemagick = {
            mimetypes = [ "application/pdf" "application/x-pdf" "image/pdf" ];
            # imagemagickBig needed because of ghostscript dependency
            cmd = ''${pkgs.imagemagickBig}/bin/convert %i[0] -background "#FFFFFF" -flatten -thumbnail %s %o'';
          };
        };
      };

      wayland.windowManager.sway.config.keybindings = {

        "${nixosConfig.ptsd.desktop.modifier}+e" = "exec pcmanfm";
        #"${cfg.modifier}+e" ="exec pcmanfm \"`${cwdCmd}`\"";

        "XF86Calculator" = "exec ${term.execFloating "${pkgs.ptsd-py3env}/bin/ipython" ""}";
      };

      home.sessionVariables = {
        NNN_PLUG = "i:nobbofin-insert";
      };

      home.file.".config/nnn/plugins/nobbofin-insert".source = "${pkgs.ptsd-python3.pkgs.nobbofin}/bin/nobbofin-insert";
    };

  services.gvfs.enable = true; # allow smb:// mounts in pcmanfm
}
