{ config, lib, pkgs, nixosConfig, ... }: {
  programs.chromium = {
    enable = !nixosConfig.ptsd.minimal;
    package = pkgs.google-chrome;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
  };
}
