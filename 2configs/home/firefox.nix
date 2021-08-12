{ config, lib, pkgs, ... }: {
  programs.firefox = {
    enable = true;
  };


  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
