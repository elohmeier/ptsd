{ config, lib, pkgs, ... }:

# Tools you probably would not add to an ISO image
let
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };
  unstable = import <nixpkgs-unstable> { };
in
{
  #imports = [
  #  <ptsd/2configs/home/irssi.nix>
  #  <ptsd/2configs/home/mbsync.nix>
  #];

  programs.broot.enable = true;

  home.packages = with pkgs; let
    mywine = wine.override { wineBuild = "wine32"; wineRelease = "staging"; };
  in
  [
    #mywine
    #(winetricks.override { wine = mywine; })
    #slack-dark
    #jetbrains.idea-ultimate
    #jetbrains.goland
    #jetbrains.pycharm-professional
    #tor-browser-bundle-bin
    xcalib
    #woeusb
    betaflight-configurator
    #nvi # needed for virsh # broken in 20.03 as of 2020-04-03
    #xca
    gcolor3
    syncthing
    geckodriver
    smbclient
    mu-repo
    file-rename
    #sublime3
    #discord
    #gnome3.evolution
    #go
    #go-bindata
    #delve
    #gofumpt
    #bitwarden-cli
    peek
    hidclient
    #AusweisApp2
    weatherbg
    #pssh
    screenkey
    hydra-check
    dfeet
    kakoune
    unstable.noisetorch # unstable has newer version than 20.09
    #sqlmap
    mumble
  ];

  home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
    rm -rf $HOME/.config/obs-studio/plugins
    mkdir -p $HOME/.config/obs-studio/plugins
    ln -sf ${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
  '';

  programs.chromium = {
    enable = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "chromium" ];
  };

  home.sessionVariables = {
    GOPATH = "/home/enno/go";

    # fix font antialiasing in mucommander
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
  };

  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    initExtra = ''
      # Johnnydecimal.com
      cjdfunction() {
        pushd ~/Pocket/*/*/''${1}*
      }
      export cjdfunction
      alias cjd="cjdfunction"
    '';
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      company
      company-tabnine
      deadgrep
      dockerfile-mode
      evil
      evil-org
      go-mode
      magit
      neotree
      nix-mode
      org
      solarized-theme
      yaml-mode
    ];
  };

  # Link emacs config to well-known path
  home.file.".emacs.d/init.el".source = config.lib.file.mkOutOfStoreSymlink /home/enno/repos/ptsd/src/init.el;
}
