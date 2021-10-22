{ config, lib, pkgs, ... }:

let
  font = "Cozette";
  fontSize = "11";
  toml = pkgs.formats.toml { };
  i3StatusRsConfig = toml.generate "i3status-rs.toml" {
    block = [
      {
        block = "custom";
        command = "echo st";
        on_click = "${myst}/bin/st";
        interval = "once";
      }
      {
        block = "custom";
        command = "echo pavucontrol";
        on_click = "${pkgs.pavucontrol}/bin/pavucontrol";
        interval = "once";
      }
      {
        block = "custom";
        command = "echo onboard";
        on_click = "${pkgs.onboard}/bin/onboard";
        interval = "once";
      }
      {
        block = "custom";
        command = "echo kill kodi";
        on_click = "${pkgs.procps}/bin/pkill -9 kodi";
        interval = "once";
      }
      {
        block = "custom";
        command = "echo B+";
        on_click = "${pkgs.brightnessctl}/bin/brightnessctl s 10%+";
        interval = "once";
      }
      {
        block = "custom";
        command = "echo B-";
        on_click = "${pkgs.brightnessctl}/bin/brightnessctl s 10%-";
        interval = "once";
      }
      {
        block = "memory";
        display_type = "memory";
        format_mem = "{mem_used_percents}";
        format_swap = "{swap_used_percents}";
      }
      {
        block = "sound";
      }
      # {
      #   block = "backlight";
      # }
      {
        block = "time";
        interval = 5;
        format = "%a %d/%m %R";
      }
    ];
  };
  st-config = pkgs.substituteAll {
    src = ./st-config.def.h;
    inherit font fontSize;
  };
  myst = pkgs.st.override { conf = builtins.readFile st-config; };
in
{
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      foot
      bemenu
    ];
  };

  services.touchegg.enable = true;

  system.activationScripts.configure-touchegg =
    let toucheggConf = pkgs.writeText "touchegg.conf" ''
      <touchégg>
        <application name="All">
          <gesture type="SWIPE" fingers="2" direction="DOWN">
            <action type="RUN_COMMAND">
              <repeat>true</repeat>
              <command>${pkgs.xdotool}/bin/xdotool click 4</command>
              <decreaseCommand>${pkgs.xdotool}/bin/xdotool click 5</decreaseCommand>
            </action>
          </gesture>
          <gesture type="SWIPE" fingers="2" direction="UP">
            <action type="RUN_COMMAND">
              <repeat>true</repeat>
              <command>${pkgs.xdotool}/bin/xdotool click 5</command>
              <decreaseCommand>${pkgs.xdotool}/bin/xdotool click 4</decreaseCommand>
            </action>
          </gesture>
        </application>
      </touchégg>
    '';
    in
    lib.stringAfter [ "users" "groups" ]
      ''
        mkdir -p /home/enno/.config/touchegg
        chown enno:users /home/enno
        chown enno:users /home/enno/.config
        chown enno:users /home/enno/.config/touchegg
        rm -f /home/enno/.config/touchegg/touchegg.conf
        ln -sf ${toucheggConf} /home/enno/.config/touchegg/touchegg.conf
      '';

  environment.variables = {
    BEMENU_OPTS = "--fn \\\"${font} ${fontSize}\\\"";
  };

  environment.systemPackages = with pkgs; [
    firefox
    glxinfo
    kodi-wayland
    pavucontrol
    myst
    xdotool
  ];

  fonts.fonts = with pkgs; [ cozette ];

  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    media-session = {
      enable = true;
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    displayManager = {
      autoLogin = {
        enable = true;
        user = "enno";
      };
      defaultSession = "none+i3";
    };
    layout = "de";
    libinput.enable = true;
    libinput.mouse.naturalScrolling = true;
    windowManager.i3.enable = true;

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };


  environment.etc."xdg/i3/config".text =
    let
      modifier = "Mod1";
    in
    ''
      set $mod ${modifier}
      floating_modifier $mod
      font xft:${font} ${fontSize}
      workspace_layout tabbed

      bindsym $mod+Return exec ${myst}/bin/st
      bindsym $mod+d exec ${pkgs.bemenu}/bin/bemenu-run

      bindsym $mod+Shift+q kill
      bindsym $mod+Shift+space floating toggle

      bindsym $mod+comma layout stacking
      bindsym $mod+period layout tabbed
      bindsym $mod+minus layout toggle split
      
      bindsym $mod+Left focus left
      bindsym $mod+h focus left
      bindsym $mod+Down focus down
      bindsym $mod+j focus down
      bindsym $mod+Up focus up
      bindsym $mod+k focus up
      bindsym $mod+Right focus right
      bindsym $mod+l focus right

      bindsym $mod+Shift+Left move left
      bindsym $mod+Shift+h move left
      bindsym $mod+Shift+Down move down
      bindsym $mod+Shift+j move down
      bindsym $mod+Shift+Up move up
      bindsym $mod+Shift+k move up
      bindsym $mod+Shift+Right move right
      bindsym $mod+Shift+l move right

      bindsym $mod+1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+7 workspace number 7
      bindsym $mod+8 workspace number 8
      bindsym $mod+9 workspace number 9
      bindsym $mod+0 workspace number 10

      bindsym $mod+Shift+1 move container to workspace number 1
      bindsym $mod+Shift+2 move container to workspace number 2
      bindsym $mod+Shift+3 move container to workspace number 3
      bindsym $mod+Shift+4 move container to workspace number 4
      bindsym $mod+Shift+5 move container to workspace number 5
      bindsym $mod+Shift+6 move container to workspace number 6
      bindsym $mod+Shift+7 move container to workspace number 7
      bindsym $mod+Shift+8 move container to workspace number 8
      bindsym $mod+Shift+9 move container to workspace number 9
      bindsym $mod+Shift+0 move container to workspace number 10

      bar {
        status_command ${pkgs.i3status-rust}/bin/i3status-rs ${i3StatusRsConfig}
      }

      #exec ${pkgs.kodi}/bin/kodi
    '';
}
