{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
  py3 = pkgs.python37;
  pyenv = py3.withPackages (
    pythonPackages: with pythonPackages; [
      black
      jupyterlab
      lxml
      keyring
      pdfminer
      pillow
      requests
      selenium
    ]
  );
in
{
  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/gpg.nix>
    <ptsd/2configs/home/mail.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/zsh.nix>

    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.packageOverrides = import ../../5pkgs pkgs;
    overlays = [
      (import ../../submodules/nix-writers/pkgs)
    ];
  };

  home.sessionVariables = {
    PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    initExtra = ''
      # Johnnydecimal.com
      cjdfunction() {
        pushd ~/Pocket/*/*/$${1}*
      }
      export cjdfunction
      alias cjd="cjdfunction"
    '';
  };

  programs.irssi = {
    enable = true;

    networks = {
      freenode = {
        nick = "nobbo";
        server = {
          address = "chat.freenode.net";
          port = 6697;
          autoConnect = true;
          ssl = {
            enable = true;
            verify = true;
          };
        };
        channels = {
          "nixos".autoJoin = true;
          "nixos-de".autoJoin = true;
          "krebs".autoJoin = true;
        };
      };
      hackint = {
        nick = "nobbo";
        server = {
          address = "irc.hackint.org";
          port = 6697;
          ssl = {
            enable = true;
            verify = true;
          };
        };
      };
    };

    extraConfig = ''
      settings = { core = { real_name = "nobbo"; user_name = "nobbo"; nick = "nobbo"; }; };
    '';
  };

  programs.emacs.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    unstable.drone-cli
    openshift
    minishift
    neomutt
    cachix
    pyenv
    virtmanager
    virtviewer
    docker_compose
    nvi # needed for virsh
    dnsmasq
    mosh
    wireshark-qt
    freerdp
    screen
    sqlitebrowser
    nixpkgs-fmt
    asciinema
    gnumake
    qrencode
    nix-deploy
    hcloud
    dep2nix
    xca
    gcolor3
    vlc
    syncthing
    imagemagick
    youtube-dl
    spotify
    mpv
    drawio
    (pass.withExtensions (ext: [ ext.pass-import ]))
    openssl
    efitools
    tpm2-tools
    lorri
    smartmontools
    gptfdisk
    gparted
    efibootmgr
    usbutils
    wirelesstools
    wpa_supplicant
    inetutils
    macchanger
    p7zip
    unrar
    mosh
    mkpasswd
    pcmanfm
    geckodriver
    smbclient
    unstable.mu-repo # not yet in 19.09
    file-rename
  ];
}
