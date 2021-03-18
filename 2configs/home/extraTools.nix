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
    #weatherbg
    #pssh
    screenkey
    hydra-check
    dfeet
  ];

  home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
    rm -rf $HOME/.config/obs-studio/plugins
    mkdir -p $HOME/.config/obs-studio/plugins
    ln -sf ${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
  '';

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
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

  # configure doom-emacs using `git clone https://github.com/hlissner/doom-emacs ~/.emacs.d` and run `~/.emacs.d/bin/doom sync`
  programs.emacs = {
    enable = true;
  };

  # Link emacs config to well-known path
  home.file.".doom.d/config.el".source = config.lib.file.mkOutOfStoreSymlink /home/enno/repos/ptsd/src/config.el;
  home.file.".doom.d/init.el".source = config.lib.file.mkOutOfStoreSymlink /home/enno/repos/ptsd/src/init.el;
  home.file.".doom.d/packages.el".source = config.lib.file.mkOutOfStoreSymlink /home/enno/repos/ptsd/src/packages.el;
}
