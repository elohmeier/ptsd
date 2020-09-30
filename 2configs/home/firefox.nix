{ config, lib, pkgs, ... }:

{
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };
}
