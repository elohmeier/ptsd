{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  config = lib.mkIf (cfg.enable && cfg.i3compat && !config.ptsd.bootstrap) {

    environment.systemPackages = with pkgs; [ arandr ];

    services.xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      displayManager.defaultSession = "none+i3";
      layout = lib.mkDefault "de";
      libinput.enable = true;
      libinput.mouse.naturalScrolling = true;
      windowManager.i3.enable = true;
    };

    ptsd.desktop.lockCmd = "${pkgs.i3lock}/bin/i3lock";

    ptsd.desktop.term = rec {
      package = pkgs.alacritty;
      binary = "${package}/bin/alacritty";
      exec = prog: dir: "${binary}${if dir != "" then " --working-directory \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}";

      # TODO: configure floating
      execFloating = prog: dir: "${binary}${if dir != "" then " --working-directory \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}";
    };

    home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
      {
        xsession.windowManager.i3 = {
          enable = true;
          config = {
            modifier = cfg.modifier;
            keybindings = import ./keybindings.nix { inherit cfg lib pkgs; };
            modes = import ./modes.nix { inherit cfg lib pkgs; };
            startup = [
              { command = toString pkgs.autoname-workspaces; }
              { command = "${pkgs.flameshot}/bin/flameshot"; }
            ];
          };
        };

        programs.alacritty = {
          enable = true;
          settings = {
            font = {
              normal = {
                family = cfg.fontMono;
              };
              size = cfg.fontSize;
            };
            env.WINIT_X11_SCALE_FACTOR = "1.0";
          };
        };
      };
  };
}
