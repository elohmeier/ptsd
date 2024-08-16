{ pkgs, ... }:
{

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
  };

  home = {
    username = "gordon";
    homeDirectory = "/home/gordon";

    packages = with pkgs; [
      bchunk
      firefox
      flameshot
      freecad
      google-chrome
      lutris
      samba
      transmission-gtk
      wine
      winetricks
      zathura
    ];
  };

  programs.mpv = {
    enable = true;
    # package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { ffmpeg_5 = pkgs.ffmpeg_5-full; }) { };
  };

  programs.ssh.extraOptionOverrides = {
    PKCS11Provider = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
  };
}
