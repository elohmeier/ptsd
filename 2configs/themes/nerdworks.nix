{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.lightdm = {
    background = "${pkgs.nerdworks-artwork}/scaled/wallpaper-n3.png";

    # move login box to bottom left and add logo
    greeters.gtk.extraConfig = ''
      default-user-image=${pkgs.nerdworks-artwork}/Logo_Farbe_Ohne_Schrift_500.png
      position=42 -42
    '';
  };
}
