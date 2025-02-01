{ config, pkgs, ... }:

{
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
  # };

  home = {
    username = "gordon";
    homeDirectory = "/home/gordon";
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin" # uv-managed
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      age
      aichat
      bc
      bchunk
      entr
      firefox
      flameshot
      freecad
      gh
      ghostty
      google-chrome
      kubectl
      libreoffice-fresh
      lutris
      ncdu
      nix-update
      nixvim-full
      podman
      ripgrep
      samba
      skopeo
      sops
      syncthing
      transmission_4-gtk
      typst
      uv
      wine
      winetricks
      yazi
      zathura
    ];
  };

  programs.fish.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/tp3-home.yaml;
    secrets."aichat-config.yaml" = { };
  };

  home.file.".config/aichat/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink
      config.sops.secrets."aichat-config.yaml".path;

  programs.mpv = {
    enable = true;
    # package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { ffmpeg_5 = pkgs.ffmpeg_5-full; }) { };
  };

  programs.nix-index-database.comma.enable = true;
}
