{ config, lib, pkgs, ... }:

{
  ptsd.desktop = {
    backgroundImage = "${pkgs.nerdworks-artwork}/scaled/wallpaper-n3.png";
    lockImage = "${pkgs.nerdworks-artwork}/Nerdworks_Hamburg_Logo_Web_Negativ_Weiss.png";
    userImage = "${pkgs.nerdworks-artwork}/Logo_Farbe_Ohne_Schrift_500.png";
  };
}
