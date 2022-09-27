{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  config = mkIf (cfg.enable && !cfg.i3compat) {
    environment.systemPackages = with pkgs;      [
      swaylock
      grim
      slurp
      wl-clipboard
      wdisplays
    ] ++ optionals cfg.qt.enable [
      qt5.qtwayland
      libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
    ];

    environment.variables = {
      # disabled to allow xwayland mode by default for sdl apps
      # SDL_VIDEODRIVER = "wayland";
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
      NIXOS_OZONE_WL = "1";
    } // optionalAttrs cfg.qt.enable {
      QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
      {
        wayland.windowManager.sway = {
          enable = true;
          config =
            {
              inherit (cfg) modifier;
              keybindings = import ./keybindings.nix { inherit cfg lib pkgs; };
              modes = import ./modes.nix { inherit cfg lib pkgs; };
              window = {
                commands = [
                  {
                    criteria.class = ".blueman-manager-wrapped";
                    command = "floating enable";
                  }
                  {
                    criteria.class = "Pavucontrol";
                    command = "floating enable";
                  }
                  {
                    criteria.title = "Firefox — Sharing Indicator";
                    command = "kill";
                  }
                  {
                    criteria.app_id = "term.floating";
                    command = "floating enable";
                  }
                ];
                hideEdgeBorders = "smart";
              };
              fonts = {
                names = [ cfg.fontSans ];
                size = cfg.fontSize;
              };
              bars = [ ];

              # use `swaymsg -t get_inputs`
              input = {
                "*" = {
                  natural_scroll = "enabled";
                  xkb_layout = lib.mkDefault "de";
                  xkb_numlock = if cfg.numlockAuto then "enabled" else "disabled";
                  repeat_delay = "200";
                  repeat_rate = "45";
                };
              };

              focus.mouseWarping = false;

              seat = {
                "*" = {
                  xcursor_theme = "Adwaita 16";
                  hide_cursor = toString (cfg.hideCursorIdleSec * 1000);
                };
              };

              startup = [
                { command = "${config.programs.waybar.package}/bin/waybar"; }
                { command = toString pkgs.autoname-workspaces; }
              ] ++ optional cfg.autolock.enable {

                command = concatStringsSep " " ([
                  "${pkgs.swayidle}/bin/swayidle -w"
                  "timeout 30 'if ${pkgs.procps}/bin/pgrep swaylock; then ${pkgs.sway}/bin/swaymsg \"output * dpms off\"; fi'" # turn off screen quickly when locked
                  "timeout 330 '${pkgs.sway}/bin/swaymsg \"output * dpms off\"'"
                  "resume '${pkgs.sway}/bin/swaymsg \"output * dpms on\"'"
                ] ++ optionals cfg.autolock.requirePassword [
                  "timeout 300 '${cfg.lockCmd}'"
                  "before-sleep '${cfg.lockCmd}'"
                ]);
              };
            };
        };


        # TODO: add wayland-instance@.target setup
        # to fix wayland-1.sock assumption issue
        # see also https://codeberg.org/dnkl/foot/src/branch/master/foot-server@.service.in
        systemd.user.services.foot-server = {
          Service = {
            ExecStart = "${pkgs.foot}/bin/foot --server=0";
            NonBlocking = true;
            StandardInput = "socket";
          };
          Unit = {
            Requires = [ "%N.socket" ];
            Description = "Foot server";
            Documentation = "man:foot(1)";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        systemd.user.sockets.foot-server = {
          Socket.ListenStream = "%t/foot-wayland-1.sock";
          Install.WantedBy = [ "sockets.target" ];
        };
      };
  };
}
