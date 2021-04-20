{ config, lib, pkgs, ... }:
{
  imports = [
    ../../2configs/home
  ];

  home.stateVersion = "20.09";
}
