{ config, pkgs, ... }:
{

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
  };

  home = {
    username = "gordon";
    homeDirectory = "/home/gordon";
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin" # uv-managed
    ];

    packages = with pkgs; [
      age
      aichat
      bc
      bchunk
      entr
      firefox
      flameshot
      freecad
      ghostty
      google-chrome
      kubectl
      libreoffice-fresh
      lutris
      nix-update
      podman
      ripgrep
      samba
      skopeo
      sops
      transmission_4-gtk
      typst
      uv
      wine
      winetricks
      zathura
    ];
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

  programs.ssh.extraOptionOverrides = {
    PKCS11Provider = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
  };

  programs.nix-index-database.comma.enable = true;
}
