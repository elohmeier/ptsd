{ config, pkgs, ... }:

let
  sshTpmAgentSocket = "/run/user/1000/gnupg/S.gpg-agent.ssh";
in
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

      SSH_AUTH_SOCK = sshTpmAgentSocket;
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
      ghostty
      google-chrome
      kubectl
      libreoffice-fresh
      lutris
      nix-update
      nixvim-full
      podman
      ripgrep
      samba
      skopeo
      sops
      ssh-tpm-agent
      syncthing
      transmission_4-gtk
      typst
      uv
      wine
      winetricks
      zathura
    ];
  };

  programs.fish.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ${sshTpmAgentSocket}
    '';
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
