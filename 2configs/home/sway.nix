{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod1";
      terminal = "foot";

      fonts = {
        names = [ "SauceCodePro Nerd Font" ];
        size = 18.0;
      };

      startup = [{ command = toString pkgs.autoname-workspaces; }];

      input."*" = {
        natural_scroll = "enabled";
        xkb_layout = "de";
        repeat_delay = "200";
        repeat_rate = "45";
      };

      # LG UltraFine
      # output."Virtual-1".mode = "--custom 4096x2304@60Hz";

      output."Dell Inc. DELL P2415Q D8VXF64G0LGL".pos = "0 0";
      output."Dell Inc. DELL P2415Q D8VXF96K09HB".pos = "0 2160";

      bars = import ./i3sway/bars.nix { inherit config pkgs; };
      keybindings = import ./i3sway/keybindings.nix { inherit config lib pkgs; };
      modes = import ./i3sway/modes.nix { inherit lib pkgs; };

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
  };
}
