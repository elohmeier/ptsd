{ config, lib, pkgs, ... }: {



  services.fluidd = {
    enable = true;
    hostName = "eee1.fritz.box";
  };

}
