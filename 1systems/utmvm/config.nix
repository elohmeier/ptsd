{ config, lib, pkgs, ... }: {

  imports = [
    ../../2configs
  ];

  environment.systemPackages = with pkgs;[
    git
  ];

}
