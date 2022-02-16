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
            fonts = {
              names = [ cfg.fontSans ];
              size = cfg.fontSize;
            };
            startup = [
              { command = toString pkgs.autoname-workspaces; }
              { command = "${pkgs.flameshot}/bin/flameshot"; }
            ];
            bars = [{
              mode = "dock";
              hiddenState = "hide";
              position = "bottom";
              workspaceButtons = true;
              workspaceNumbers = true;
              statusCommand = "${pkgs.i3status}/bin/i3status";
              fonts = {
                names = [ cfg.fontSans ];
                size = cfg.fontSize;
              };
              trayOutput = "primary";
              colors = {
                background = "#000000";
                statusline = "#ffffff";
                separator = "#666666";
                focusedWorkspace = {
                  border = "#4c7899";
                  background = "#285577";
                  text = "#ffffff";
                };
                activeWorkspace = {
                  border = "#333333";
                  background = "#5f676a";
                  text = "#ffffff";
                };
                inactiveWorkspace = {
                  border = "#333333";
                  background = "#222222";
                  text = "#888888";
                };
                urgentWorkspace = {
                  border = "#2f343a";
                  background = "#900000";
                  text = "#ffffff";
                };
                bindingMode = {
                  border = "#2f343a";
                  background = "#900000";
                  text = "#ffffff";
                };
              };
            }];
          };
        };

        programs.i3status = {
          enable = true;
          enableDefault = false;
          general = {
            colors = true;
            interval = 5;
          };
          modules = {
            ipv6.position = 1;

            "wireless _first_" = {
              position = 2;
              settings = {
                format_up = "  (%quality at %essid) %ip";
                format_down = "  down";
              };
            };

            "ethernet _first_" = {
              position = 3;
              settings = {
                format_up = "ﯱ e: %ip (%speed)";
                format_down = " e: down";
              };
            };

            "ethernet nwvpn" = {
              position = 3;
              settings = {
                format_up = "旅 nw: %ip";
                format_down = " nw: down";
              };
            };

            "ethernet tun0" = {
              position = 3;
              settings = {
                format_up = "旅 t0: %ip";
                format_down = " t0: down";
              };
            };

            "battery all" = {
              position = 4;
              settings = { format = "%status %percentage %remaining"; };
            };

            "disk /" = {
              position = 5;
              settings.format = " / %avail";
            };

            "disk /home" = {
              position = 5;
              settings.format = " h %avail";
            };

            "disk /nix" = {
              position = 5;
              settings.format = " n %avail";
            };

            "disk /run/user/1000" = {
              position = 5;
              settings.format = " xrd %avail";
            };

            load = {
              position = 6;
              settings = {
                format = " %1min";
              };
            };

            memory = {
              position = 7;
              settings = {
                format = " %used | %available";
                threshold_degraded = "1G";
                format_degraded = "MEMORY < %available";
              };
            };

            "tztime local" = {
              position = 8;
              settings = { format = "%Y-%m-%d %H:%M:%S"; };
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
            env.WINIT_X11_SCALE_FACTOR = "1.0";
          };
        };
      };
  };
}
