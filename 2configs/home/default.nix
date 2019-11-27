{ config, lib, pkgs, ... }:

let
  py3 = pkgs.python3;
  pyenv = py3.withPackages (
    pythonPackages: with pythonPackages; [
      black
      jupyterlab
      requests
    ]
  );
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    initExtra = ''
      echo "Easy choices, hard life. Hard choices, easy life..."

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

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    unstable.drone-cli
    openshift
    minishift
    neomutt
    cachix
    pssh
    pyenv
    bc
    wget
    mc
    tig
    killall
    unzip
    whois
    ncdu
    iftop
    bind
    nmap
    htop
    cryptsetup
    ntfs-3g
    virtmanager
    virtviewer
    docker_compose
    nvi # needed for virsh
    dnsmasq
    mosh
    wireguard-qt
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
  ];
}
