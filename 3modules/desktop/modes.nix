{ cfg }:

{
  "${cfg.exit_mode}" = {
    "l" = if cfg.i3compat then ''exec i3-msg exit; mode "default"'' else ''exec swaymsg exit; mode "default"'';
    "r" = ''exec systemctl reboot; mode "default"'';
    "w" = ''exec systemctl reboot --boot-loader-entry=auto-windows; mode "default"'';
    "s" = ''exec systemctl poweroff; mode "default"'';
    "u" = ''exec systemctl suspend-then-hibernate; mode "default"'';
    "p" = ''exec systemctl suspend; mode "default"'';
    "h" = ''exec systemctl hibernate; mode "default"'';
    "Escape" = ''mode "default"'';
    "Return" = ''mode "default"'';
  };

  resize = {
    "Left" = "resize shrink width 10 px or 10 ppt";
    "Down" = "resize grow height 10 px or 10 ppt";
    "Up" = "resize shrink height 10 px or 10 ppt";
    "Right" = "resize grow width 10 px or 10 ppt";
    "Escape" = "mode default";
    "Return" = "mode default";
    "${cfg.modifier}+r" = "mode default";
    "j" = "resize shrink width 10 px or 10 ppt";
    "k" = "resize grow height 10 px or 10 ppt";
    "l" = "resize shrink height 10 px or 10 ppt";
    "odiaeresis" = "resize grow width 10 px or 10 ppt";
  };

  # vim-style window splits and resizing after hitting mod+w
  window = {
    "s" = "split v; mode \"default\"";
    "v" = "split h; mode \"default\"";
    "Shift+comma" = "resize shrink width 10 ppt or 10 px";
    "Shift+period" = "resize grow width 10 ppt or 10 px";
    "Shift+equal" = "resize grow height 10 ppt or 10 px";
    "Shift+minus" = "resize shrink height 10 ppt or 10 px";

    # leave window mode
    "Return" = "mode \"default\"";
    "Escape" = "mode \"default\"";
  };
}
