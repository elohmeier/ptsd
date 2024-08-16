{
  config,
  lib,
  pkgs,
  ...
}:

{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod1";
      terminal = "foot";

      fonts = {
        names = [ "SauceCodePro Nerd Font" ];
        size = 11.0;
      };

      startup = [ { command = toString pkgs.autoname-workspaces; } ];

      input = {
        "*" = {
          natural_scroll = "enabled";
          xkb_layout = "de";
          repeat_delay = "200";
          repeat_rate = "45";
        };

        "1118:2092:Microsoft_Microsoft_Ergonomic_Keyboard".xkb_numlock = "enabled";

        "0:0:PinePhone_Keyboard" = {
          xkb_file = toString ./pinephone-keyboard.xkb;
          repeat_delay = "500";
          repeat_rate = "15";
        };

        "12951:6505:ZSA_Technology_Labs_Moonlander_Mark_I".xkb_layout = "us";
        "12951:6505:ZSA_Technology_Labs_Moonlander_Mark_I_Consumer_Control".xkb_layout = "us";
        "12951:6505:ZSA_Technology_Labs_Moonlander_Mark_I_Keyboard".xkb_layout = "us";
        "12951:6505:ZSA_Technology_Labs_Moonlander_Mark_I_System_Control".xkb_layout = "us";

        # pine2
        "1046:1158:Goodix_Capacitive_TouchScreen".map_to_output = "DSI-1";
      };

      # pine2
      output.DSI-1.transform = "90";

      # LG UltraFine
      # output."Virtual-1".mode = "--custom 4096x2304@60Hz";

      output."Dell Inc. DELL P2415Q D8VXF64G0LGL".pos = "0 0";
      output."Dell Inc. DELL P2415Q D8VXF96K09HB".pos = "0 2160";

      bars = import ./i3sway/bars.nix { inherit config pkgs; };
      keybindings = import ./i3sway/keybindings.nix { inherit config lib pkgs; };
      modes = import ./i3sway/modes.nix { inherit pkgs; };

      window = {
        commands = [
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

      seat."*".xcursor_theme = "Adwaita 16";

      colors = with config.ptsd.style.colors; {
        focused = {
          border = base05;
          background = base0D;
          text = base00;
          indicator = base0D;
          childBorder = base0D;
        };
        focusedInactive = {
          border = base01;
          background = base01;
          text = base05;
          indicator = base01;
          childBorder = base01;
        };
        unfocused = {
          border = base01;
          background = base00;
          text = base05;
          indicator = base01;
          childBorder = base01;
        };
        urgent = {
          border = base08;
          background = base08;
          text = base00;
          indicator = base08;
          childBorder = base08;
        };
        placeholder = {
          border = base00;
          background = base00;
          text = base05;
          indicator = base00;
          childBorder = base00;
        };
        background = base07;
      };
    };

    extraConfig = ''
      set $WOBSOCK $XDG_RUNTIME_DIR/wob.sock
    '';
  };

  # notfication daemon
  programs.mako = with config.ptsd.style.colorsHex; {
    enable = true;
    font = "SauceCodePro Nerd Font 18";
    defaultTimeout = 3000;
    backgroundColor = base00;
    textColor = base05;
    borderColor = base0D;

    extraConfig = lib.generators.toINI { } {
      "urgency = low " = {
        background-color = base00;
        text-color = base0A;
        border-color = base0D;
      };
      "
          urgency=high" = {
        background-color = base00;
        text-color = base08;
        border-color = base0D;
      };
    };
  };

  # OSD
  systemd.user.services.wob = {
    Unit = {
      Description = "Overlay bar for Wayland";
      Documentation = "man:wob(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      StandardInput = "socket";
      ExecStart = "${pkgs.wob}/bin/wob --anchor bottom --anchor right --margin 50";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.sockets.wob = {
    Socket = {
      ListenFIFO = "%t/wob.sock";
      SocketMode = "0600";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };
}
