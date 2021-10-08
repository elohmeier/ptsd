{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  config = lib.mkIf (cfg.enable && cfg.i3compat) {
    services.xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      displayManager.defaultSession = "none+i3";
      layout = "de";
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
            modes = import ./modes.nix { inherit cfg; };
            fonts = {
              names = [ cfg.fontSans ];
              size = cfg.fontSize;
            };
            startup = [
              { command = toString pkgs.autoname-workspaces; }
            ];
          };
        };

        programs.i3status = {
          enable = true;
          enableDefault = true;
          modules = {
            "ethernet nwvpn" = {
              position = 3;
              settings = {
                format_up = "nw: %ip";
                format_down = "nw: down";
              };
            };

            "ethernet tun0" = {
              position = 3;
              settings = {
                format_up = "t0: %ip";
                format_down = "t0: down";
              };
            };

            "disk /home" = {
              position = 5;
              settings.format = "h %avail";
            };

            "disk /nix" = {
              position = 5;
              settings.format = "n %avail";
            };

            "disk /run/user/1000" = {
              position = 5;
              settings.format = "xrd %avail";
            };
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
          };
        };
      };
  };
}
