{ config, lib, pkgs, ... }: {
  programs.chromium = {
    enable = !config.ptsd.minimal;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
  };
}
