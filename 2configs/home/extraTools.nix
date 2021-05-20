{ config, lib, pkgs, ... }:

{

  programs.broot.enable = true;

  home.packages = with pkgs; let
    mywine = wine.override { wineBuild = "wine32"; wineRelease = "staging"; };
  in
  [
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
  ];

  # home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
  #   rm -rf $HOME/.config/obs-studio/plugins
  #   mkdir -p $HOME/.config/obs-studio/plugins
  #   ln -sf ${pkgs.obs-v4l2sink}/share/obs/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
  # '';

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "chromium" "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };

  home.sessionVariables = {
    GOPATH = "/home/enno/go";

    # fix font antialiasing in mucommander
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
  };

  nixpkgs.config.allowUnfree = true;

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ../../src/doom.d;
  };

}
