{ nixosConfig, pkgs, ... }:

let
  cfg = nixosConfig.ptsd.desktop;
in
{
  gtk = {
    enable = true;
    font = {
      name = cfg.fontSans;
      size = builtins.floor cfg.fontSize;
      package = pkgs.iosevka; # TODO: replace, pulls in i686-unsupported dependencies
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
  };
}
