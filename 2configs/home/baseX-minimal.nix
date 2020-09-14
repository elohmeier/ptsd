{ config, lib, pkgs, ... }:

{
  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
  };

  #ptsd.urxvt.enable = true;
  #ptsd.alacritty.enable = true;
  ptsd.kitty.enable = true;
}
