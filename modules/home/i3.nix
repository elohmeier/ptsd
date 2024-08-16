{
  config,
  lib,
  pkgs,
  ...
}:

{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod1";
      terminal = "alacritty";

      fonts = {
        names = [ "SauceCodePro Nerd Font" ];
        size = 18.0;
      };

      startup = [
        { command = toString pkgs.autoname-workspaces; }
        # { command = "${pkgs.spice-vdagent}/bin/spice-vdagent"; }
      ];

      bars = import ./i3sway/bars.nix { inherit config pkgs; };
      keybindings = import ./i3sway/keybindings.nix {
        inherit config lib pkgs;
        termExec =
          prog: dir:
          "${config.programs.alacritty.package}/bin/alacritty${
            if dir != "" then " --working-directory \"${dir}\"" else ""
          }${if prog != "" then " -e ${prog}" else ""}";
      };
      modes = import ./i3sway/modes.nix {
        inherit lib pkgs;
        i3compat = true;
      };

      colors = with config.ptsd.style.colorsHex; {
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
  };

  home.packages = [
    (pkgs.writeShellScriptBin "xrandr-utm-lg4k" ". ${../../4scripts/xrandr-utm.sh} 4096 2304")
    (pkgs.writeShellScriptBin "xrandr-utm-mb16" ". ${../../4scripts/xrandr-utm.sh} 3456 2234")
  ];
}
