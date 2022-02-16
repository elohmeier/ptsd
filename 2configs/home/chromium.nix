{ config, lib, pkgs,nixosConfig, ... }: {
  programs.chromium = {
    enable = !nixosConfig.ptsd.minimal;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
  };
}
