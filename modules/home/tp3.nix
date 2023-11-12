{ pkgs, ... }: {

  home.packages = with pkgs; [
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
  ];

  programs.mpv = {
    enable = true;
    package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { ffmpeg_5 = pkgs.ffmpeg_5-full; }) { };
  };

  programs.ssh.extraOptionOverrides = {
    PKCS11Provider = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
  };
}
