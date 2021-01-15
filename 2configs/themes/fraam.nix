{ config, lib, pkgs, ... }:
let
  nwlock = pkgs.nwlock.override { imageName = "fraam_weiss.png"; };
in
{
  services.xserver.displayManager.lightdm = {
    background = "${pkgs.nerdworks-artwork}/scaled/wallpaper-fraam-2021-dark.png";

    # move login box to bottom left and add logo
    greeters.gtk.extraConfig = ''
      default-user-image=${pkgs.nerdworks-artwork}/fraam_steuerrad_500.png
      position=42 -42
    '';
  };

  ptsd.desktop.lockCmd = "${nwlock}/bin/nwlock";

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        services.screen-locker = {
          enable = true;
          lockCmd = "${nwlock}/bin/nwlock";
          xssLockExtraOptions = [
            "-n"
            "${nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
            "-l" # make sure not to allow machine suspend before the screen saver is active
          ];
        };

        home.packages = [ nwlock ];

        wayland.windowManager.sway.extraConfig = ''
          output "*" bg ${pkgs.nerdworks-artwork}/scaled/wallpaper-fraam-2021-dark.png fill
        '';
      };
  };
}
