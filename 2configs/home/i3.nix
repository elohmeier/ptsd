{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod1";
      terminal = "urxvt";

      fonts = {
        names = [ "SauceCodePro Nerd Font" ];
        size = 18.0;
      };

      startup = [
        { command = toString pkgs.autoname-workspaces; }
        { command = "${pkgs.spice-vdagent}/bin/spice-vdagent"; }
      ];

      bars = import ./i3sway/bars.nix { inherit config pkgs; };
      keybindings = import ./i3sway/keybindings.nix { inherit lib pkgs; termExec = prog: dir: "${config.programs.urxvt.package}/bin/urxvt${if dir != "" then " -cd \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}"; };
      modes = import ./i3sway/modes.nix { inherit lib pkgs; i3compat = true; };

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
}
