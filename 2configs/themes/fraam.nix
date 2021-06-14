{ config, lib, pkgs, ... }:

{
  ptsd.desktop = {
    #backgroundImage = "${pkgs.nerdworks-artwork}/scaled/wallpaper-fraam-2021-dark.png";
    backgroundImage = "/home/enno/Pocket/P1080645.jpg";
    lockImage = "${pkgs.nerdworks-artwork}/fraam_weiss.png";
    userImage = "${pkgs.nerdworks-artwork}/fraam_steuerrad_500.png";
    backgroundFill = "#193657";
  };
}
