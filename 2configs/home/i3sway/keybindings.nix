{ config
, lib
, pkgs
, modifier ? "Mod1"
, extraKeybindings ? { }
, enableFlameshot ? false
, termExec ? prog: dir: "${pkgs.foot}/bin/foot${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}"
, lockCmd ? "${pkgs.swaylock}/bin/swaylock --color 000000 -f"
, cwdCmd ? "${pkgs.swaycwd}/bin/swaycwd"
, exit_mode ? "exit: [l]ogout, [r]eboot, [e]ntry..., [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end"
, enableAudio ? false
}:

with lib;
let
  modOther = if modifier == "Mod1" then "Mod4" else "Mod1";
in
{
  "${modifier}+Return" = "exec ${termExec "" ""}";
  "${modifier}+Shift+q" = "kill";

  "${modifier}+Shift+a" = "exec xrandr --output Virtual-1 --auto";

  "${modifier}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run --list 10 --prompt 'Run:' ${config.ptsd.style.bemenuOpts}";
  #"${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu -p \"Run:\" -l 10 | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec";

  # change focus
  "${modifier}+h" = "focus left";
  "${modifier}+j" = "focus down";
  "${modifier}+k" = "focus up";
  "${modifier}+l" = "focus right";
  "${modifier}+g" = "focus next";
  "${modifier}+Shift+g" = "focus prev";

  "${modifier}+${modOther}+h" = "workspace prev_on_output";
  "${modifier}+${modOther}+l" = "workspace next_on_output";
  "${modifier}+${modOther}+Left" = "workspace prev_on_output";
  "${modifier}+${modOther}+Right" = "workspace next_on_output";

  # move focused window
  "${modifier}+Shift+h" = "move left";
  "${modifier}+Shift+j" = "move down";
  "${modifier}+Shift+k" = "move up";
  "${modifier}+Shift+l" = "move right";

  "${modifier}+f" = "fullscreen toggle";

  # change layouts with mod+,.-
  "${modifier}+comma" = "layout stacking";
  "${modifier}+period" = "layout tabbed";
  "${modifier}+minus" = "layout toggle split";

  # toggle floating
  "${modifier}+Shift+space" = "floating toggle";

  # swap focus between tiling and floating windows
  "${modifier}+space" = "focus mode_toggle";

  # move focus to parent container
  "${modifier}+a" = "focus parent";

  # move windows in and out of the scratchpad
  "${modifier}+Shift+t" = "move scratchpad";
  "${modifier}+t" = "scratchpad show";

  # cycle through border styles
  "${modifier}+b" = "border toggle";

  # "Space-Hack" to fix the ordering in the generated config file
  # This prevents that i3 uses this order: 10, 1, 2, ...
  " ${modifier}+1" = "workspace number 1";
  " ${modifier}+2" = "workspace number 2";
  " ${modifier}+3" = "workspace number 3";
  " ${modifier}+4" = "workspace number 4";
  " ${modifier}+5" = "workspace number 5";
  " ${modifier}+6" = "workspace number 6";
  " ${modifier}+7" = "workspace number 7";
  " ${modifier}+8" = "workspace number 8";
  " ${modifier}+9" = "workspace number 9";
  "${modifier}+0" = "workspace number 10";

  "${modifier}+Shift+1" = "move container to workspace number 1";
  "${modifier}+Shift+2" = "move container to workspace number 2";
  "${modifier}+Shift+3" = "move container to workspace number 3";
  "${modifier}+Shift+4" = "move container to workspace number 4";
  "${modifier}+Shift+5" = "move container to workspace number 5";
  "${modifier}+Shift+6" = "move container to workspace number 6";
  "${modifier}+Shift+7" = "move container to workspace number 7";
  "${modifier}+Shift+8" = "move container to workspace number 8";
  "${modifier}+Shift+9" = "move container to workspace number 9";
  "${modifier}+Shift+0" = "move container to workspace number 10";

  "${modifier}+Control+${modOther}+h" = "move container to workspace prev_on_output";
  "${modifier}+Control+${modOther}+l" = "move container to workspace next_on_output";

  "${modifier}+Shift+r" = "reload";

  "${modifier}+r" = "mode \"resize\"";
  "${modifier}+w" = "mode \"window\"";

  "${modifier}+Shift+Delete" = "exec ${lockCmd}";
  "${modifier}+Shift+Return" = "exec ${termExec "" "`${cwdCmd}`"}";

  "${modifier}+Shift+w" = "exec ${termExec "nmtui" ""}";

  "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%+ | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";
  "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%- | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";

  "XF86AudioMute" = mkIf (enableAudio && cfg.primarySpeaker != null)
    "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --toggle-mute && (${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-mute && echo 0 > $WOBSOCK ) || ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
  "XF86AudioLowerVolume" = mkIf (enableAudio && cfg.primarySpeaker != null)
    "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --unmute --decrease 5 && ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
  "XF86AudioRaiseVolume" = mkIf (enableAudio && cfg.primarySpeaker != null)
    "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --unmute --increase 5 && ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
  "XF86AudioMicMute" = mkIf (enableAudio && cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

  #"XF86Calculator" = lib.mkDefault "exec ${cfg.term.execFloating "${pkgs.bc}/bin/bc -l" ""}";
  "XF86HomePage" = "exec firefox";
  "XF86Search" = "exec firefox";
  "XF86Mail" = "exec evolution";
  "XF86Launch5" = "exec spotify"; # Label: 1
  "XF86Launch8" = mkIf enableAudio "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo -5%"; # Label: 4
  "XF86Launch9" = mkIf enableAudio "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo +5%"; # Label: 5

  "XF86AudioPlay" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl play-pause";
  "${modifier}+p" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl play-pause";
  "XF86AudioStop" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl stop";
  "XF86AudioNext" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl next";
  "${modifier}+n" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl next";
  "XF86AudioPrev" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl previous";
  "${modifier}+Shift+n" = mkIf enableAudio "exec ${pkgs.playerctl}/bin/playerctl previous";

  "${modifier}+Shift+u" = "resize shrink width 20 px or 20 ppt";
  "${modifier}+Shift+i" = "resize shrink height 20 px or 20 ppt";
  "${modifier}+Shift+o" = "resize grow height 20 px or 20 ppt";
  "${modifier}+Shift+p" = "resize grow width 20 px or 20 ppt";

  "${modifier}+Home" = "workspace number 1";
  "${modifier}+Prior" = "workspace prev";
  "${modifier}+Next" = "workspace next";
  "${modifier}+End" = "workspace number 10";
  "${modifier}+Tab" = "workspace back_and_forth";

  # not working
  #"${modifier}+p" = ''[instance="scratch-term"] scratchpad show'';

  "${modifier}+Shift+e" = ''mode "${exit_mode}"'';

  #"${modifier}+numbersign" = "split horizontal;; exec ${termExec "" "`${cwdCmd}`"}";
  #"${modifier}+minus" = "split vertical;; exec ${termExec "" "`${cwdCmd}`"}";

  #"${modifier}+a" = ''[class="Firefox"] scratchpad show'';
  #"${modifier}+b" = ''[class="Firefox"] scratchpad show'';

  "${modifier}+e" = "exec pcmanfm";
  #"${modifier}+e" ="exec pcmanfm \"`${cwdCmd}`\"";

  # screenshots
  "Print" = ''exec ${pkgs.grim}/bin/grim -t png ~/Pocket/Screenshots/$(${pkgs.coreutils}/bin/date +"%Y-%m-%d_%H:%M:%S.png")'';
  "${modifier}+Ctrl+Shift+4" = if enableFlameshot then "exec ${pkgs.flameshot}/bin/flameshot gui" else
    #''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
  ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -'';
} // extraKeybindings
