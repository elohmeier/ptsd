{ config, lib, pkgs, ... }: {



  services.fluidd = {
    enable = true;
  };
  services.moonraker = {
    enable = true;

  };
}
