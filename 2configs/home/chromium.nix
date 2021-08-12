{ config, lib, pkgs, ... }: {
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
  };

  programs.browserpass = {
    enable = true;
    browsers = [ "chromium" ];
  };
}
