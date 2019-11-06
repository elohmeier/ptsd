{ config, pkgs, ...}:
with import <ptsd/lib>;

{
  programs.zsh = {
    enable = true;

    initExtra = ''
      echo "Hello from PTSD"
    '';
  };
}
