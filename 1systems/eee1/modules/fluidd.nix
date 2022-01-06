{ config, lib, pkgs, ... }:
{
  services.fluidd = {
    enable = true;
    hostName = "eee1.fritz.box";
    nginx = {
      # allow large uploads from slicer
      extraConfig = ''
        client_max_body_size 20M;
      '';
    };
  };
}
