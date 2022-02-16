{ cfg, lib, pkgs }:

with lib;
{
  "${cfg.modifier}+Return" = "exec ${cfg.term.exec "" ""}";
  "${cfg.modifier}+Shift+q" = "kill";
  "${cfg.modifier}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run --list 10 --prompt 'Run:'";

  #"${cfg.modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu -p \"Run:\" -l 10 | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec";

  # change focus
  "${cfg.modifier}+h" = "focus left";
  "${cfg.modifier}+j" = "focus down";
  "${cfg.modifier}+k" = "focus up";
  "${cfg.modifier}+l" = "focus right";
  "${cfg.modifier}+Left" = "focus left";
  "${cfg.modifier}+Down" = "focus down";
  "${cfg.modifier}+Up" = "focus up";
  "${cfg.modifier}+Right" = "focus right";
  "${cfg.modifier}+g" = "focus next";
  "${cfg.modifier}+Shift+g" = "focus prev";

  "${cfg.modifier}+Mod1+h" = "workspace prev_on_output";
  "${cfg.modifier}+Mod1+l" = "workspace next_on_output";
  "${cfg.modifier}+Mod1+Left" = "workspace prev_on_output";
  "${cfg.modifier}+Mod1+Right" = "workspace next_on_output";

  # move focused window
  "${cfg.modifier}+Shift+h" = "move left";
  "${cfg.modifier}+Shift+j" = "move down";
  "${cfg.modifier}+Shift+k" = "move up";
  "${cfg.modifier}+Shift+l" = "move right";
  "${cfg.modifier}+Shift+Left" = "move left";
  "${cfg.modifier}+Shift+Down" = "move down";
  "${cfg.modifier}+Shift+Up" = "move up";
  "${cfg.modifier}+Shift+Right" = "move right";

  "${cfg.modifier}+f" = "fullscreen toggle";

  # change layouts with mod+,.-
  "${cfg.modifier}+comma" = "layout stacking";
  "${cfg.modifier}+period" = "layout tabbed";
  "${cfg.modifier}+minus" = "layout toggle split";

  # toggle floating
  "${cfg.modifier}+Shift+space" = "floating toggle";

  # swap focus between tiling and floating windows
  "${cfg.modifier}+space" = "focus mode_toggle";

  # move focus to parent container
  "${cfg.modifier}+a" = "focus parent";

  # move windows in and out of the scratchpad
  "${cfg.modifier}+Shift+t" = "move scratchpad";
  "${cfg.modifier}+t" = "scratchpad show";

  # cycle through border styles
  "${cfg.modifier}+b" = "border toggle";

  # "Space-Hack" to fix the ordering in the generated config file
  # This prevents that i3 uses this order: 10, 1, 2, ...
  " ${cfg.modifier}+1" = "workspace number 1";
  " ${cfg.modifier}+2" = "workspace number 2";
  " ${cfg.modifier}+3" = "workspace number 3";
  " ${cfg.modifier}+4" = "workspace number 4";
  " ${cfg.modifier}+5" = "workspace number 5";
  " ${cfg.modifier}+6" = "workspace number 6";
  " ${cfg.modifier}+7" = "workspace number 7";
  " ${cfg.modifier}+8" = "workspace number 8";
  " ${cfg.modifier}+9" = "workspace number 9";
  "${cfg.modifier}+0" = "workspace number 10";

  "${cfg.modifier}+Shift+1" = "move container to workspace number 1";
  "${cfg.modifier}+Shift+2" = "move container to workspace number 2";
  "${cfg.modifier}+Shift+3" = "move container to workspace number 3";
  "${cfg.modifier}+Shift+4" = "move container to workspace number 4";
  "${cfg.modifier}+Shift+5" = "move container to workspace number 5";
  "${cfg.modifier}+Shift+6" = "move container to workspace number 6";
  "${cfg.modifier}+Shift+7" = "move container to workspace number 7";
  "${cfg.modifier}+Shift+8" = "move container to workspace number 8";
  "${cfg.modifier}+Shift+9" = "move container to workspace number 9";
  "${cfg.modifier}+Shift+0" = "move container to workspace number 10";

  "${cfg.modifier}+Control+Mod1+h" = "move container to workspace prev_on_output";
  "${cfg.modifier}+Control+Mod1+l" = "move container to workspace next_on_output";
  "${cfg.modifier}+Control+Mod1+Left" = "move container to workspace prev_on_output";
  "${cfg.modifier}+Control+Mod1+Right" = "move container to workspace next_on_output";

  "${cfg.modifier}+Shift+r" = "reload";

  "${cfg.modifier}+r" = "mode \"resize\"";
  "${cfg.modifier}+w" = "mode \"window\"";

  "${cfg.modifier}+Shift+Delete" = "exec ${cfg.lockCmd}";
  "${cfg.modifier}+Shift+Return" = "exec ${cfg.term.exec "" "`${cfg.cwdCmd}`"}";

  "${cfg.modifier}+Shift+w" = "exec ${cfg.term.exec "nmtui" ""}";

  "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%+ | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";
  "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%- | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";

  "XF86AudioMute" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null)
    "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --toggle-mute && (${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-mute && echo 0 > $WOBSOCK ) || ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
  "XF86AudioLowerVolume" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null)
    "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --unmute --decrease 5 && ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
  "XF86AudioRaiseVolume" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null)
    "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --unmute --increase 5 && ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
  "XF86AudioMicMute" = mkIf (cfg.audio.enable && cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

  "XF86Calculator" = lib.mkDefault "exec ${cfg.term.execFloating "${pkgs.bc}/bin/bc -l" ""}";
  "XF86HomePage" = "exec firefox";
  "XF86Search" = "exec firefox";
  "XF86Mail" = "exec evolution";
  "XF86Launch5" = "exec spotify"; # Label: 1
  "XF86Launch8" = mkIf cfg.audio.enable "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo -5%"; # Label: 4
  "XF86Launch9" = mkIf cfg.audio.enable "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo +5%"; # Label: 5

  "XF86AudioPlay" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl play-pause";
  "${cfg.modifier}+p" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl play-pause";
  "XF86AudioStop" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl stop";
  "XF86AudioNext" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl next";
  "${cfg.modifier}+n" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl next";
  "XF86AudioPrev" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl previous";
  "${cfg.modifier}+Shift+n" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl previous";

  "${cfg.modifier}+Shift+u" = "resize shrink width 20 px or 20 ppt";
  "${cfg.modifier}+Shift+i" = "resize shrink height 20 px or 20 ppt";
  "${cfg.modifier}+Shift+o" = "resize grow height 20 px or 20 ppt";
  "${cfg.modifier}+Shift+p" = "resize grow width 20 px or 20 ppt";

  "${cfg.modifier}+Home" = "workspace number 1";
  "${cfg.modifier}+Prior" = "workspace prev";
  "${cfg.modifier}+Next" = "workspace next";
  "${cfg.modifier}+End" = "workspace number 10";
  "${cfg.modifier}+Tab" = "workspace back_and_forth";

  # not working
  #"${cfg.modifier}+p" = ''[instance="scratch-term"] scratchpad show'';

  "${cfg.modifier}+Shift+e" = ''mode "${cfg.exit_mode}"'';

  #"${cfg.modifier}+numbersign" = "split horizontal;; exec ${cfg.term.exec "" "`${cwdCmd}`"}";
  #"${cfg.modifier}+minus" = "split vertical;; exec ${cfg.term.exec "" "`${cwdCmd}`"}";

  #"${cfg.modifier}+a" = ''[class="Firefox"] scratchpad show'';
  #"${cfg.modifier}+b" = ''[class="Firefox"] scratchpad show'';

  "${cfg.modifier}+e" = "exec pcmanfm";
  #"${cfg.modifier}+e" ="exec pcmanfm \"`${cwdCmd}`\"";

  # screenshots
  "Print" = ''exec ${pkgs.grim}/bin/grim -t png ~/Pocket/Screenshots/$(${pkgs.coreutils}/bin/date +"%Y-%m-%d_%H:%M:%S.png")'';
  "${cfg.modifier}+Ctrl+Shift+4" = if cfg.i3compat then "exec ${pkgs.flameshot}/bin/flameshot gui" else
    #''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
  ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -'';
} // cfg.keybindings
