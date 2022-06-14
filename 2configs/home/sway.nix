{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod1";
      terminal = "foot";

      input."*" = {
        natural_scroll = "enabled";
        xkb_layout = "de";
        repeat_delay = "200";
        repeat_rate = "45";
      };

      # LG UltraFine
      output."Virtual-1".mode = "--custom 4096x2304@60Hz";

      output."Dell Inc. DELL P2415Q D8VXF64G0LGL".pos = "0 0";
      output."Dell Inc. DELL P2415Q D8VXF96K09HB".pos = "0 2160";

      keybindings = import ./utils/keybindings.nix { inherit lib pkgs; };
      modes = import ./utils/modes.nix { inherit lib pkgs; };
    };
  };
}
