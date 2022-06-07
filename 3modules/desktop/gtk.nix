{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  config = lib.mkIf (cfg.enable && !config.ptsd.bootstrap) {
    home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
      {
        gtk = {
          enable = true;
          font = {
            name = cfg.fontSans;
            size = builtins.floor cfg.fontSize;
            #package = pkgs.iosevka; # TODO: replace, pulls in i686-unsupported dependencies
          };
          iconTheme = {
            name = "Adwaita";
            package = pkgs.gnome3.adwaita-icon-theme;
          };
        };

        dconf.enable = true;
      };

    services.dbus.packages = [ pkgs.dconf ];
  };
}
