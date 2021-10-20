{ config, lib, pkgs, ... }:

let
  font = "Source Code Pro";
  fontSize = "8";
  alacrittyConfig = pkgs.writeText "alacritty.yml" ''
    font:
      normal:
        family: ${font}
      size: ${fontSize}
  '';
  toml = pkgs.formats.toml { };
  i3StatusRsConfig = toml.generate "i3status-rs.toml" {
    block = [
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
in
{
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      foot
      bemenu
    ];
  };

  environment.systemPackages = with pkgs; [
    firefox
    glxinfo
    kodi-wayland
    pavucontrol
  ];

  fonts.fonts = with pkgs; [ source-code-pro ];

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

      font pango:${font} ${fontSize}
      bindsym $mod+Return exec ${pkgs.alacritty}/bin/alacritty --config-file ${alacrittyConfig}
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

      exec ${pkgs.kodi}/bin/kodi
    '';

  # home-manager.users.enno = { config, nixosConfig, lib, pkgs, ... }:
  #   {
  #     wayland.windowManager.sway = {
  #       enable = true;
  #       config = {
  #         bars = [{
  #           command = "${pkgs.waybar}/bin/waybar";
  #         }];

  #         input = {
  #           "*" = {
  #             xkb_layout = "de";
  #           };

  #           raspberrypi-ts = {
  #             map_to_output = "DSI-1";
  #           };
  #         };

  #         # output.DSI-1.bg = "#000000 solid_color";
  #         output."*".bg = "#000000 solid_color";

  #         menu = "${pkgs.bemenu}/bin/bemenu-run --fn '${font}'";
  #         modifier = lib.mkDefault "Mod4";
  #         terminal = "${pkgs.foot}/bin/footclient";
  #       };
  #     };

  #     programs.foot = {
  #       enable = true;
  #       server.enable = true;
  #       settings = {
  #         main = {
  #           font = "${font}:size=${fontSize}";
  #           dpi-aware = "yes";
  #         };
  #       };
  #     };

  #     programs.waybar = {
  #       enable = true;
  #       settings = [{
  #         layer = "top";
  #         position = "top";
  #         height = 40;
  #         # output = [ "DSI-1" ];
  #         modules-left = [ "sway/workspaces" "sway/mode" ];
  #         modules-center = [ ];
  #         modules-right = [ "network" "cpu" "memory" "temperature" "clock" "tray" ];
  #         modules = {
  #           "sway/workspaces" = {
  #             disable-scroll = true;
  #             all-outputs = true;
  #           };
  #         };
  #       }];
  #       style = ''
  #         * {
  #           border: none;
  #           border-radius: 0;
  #           font-family: Source Code Pro;
  #           }
  #         window#waybar {
  #           background: #111111;
  #           color: #FFFFFF;
  #         }
  #         #workspaces button {
  #           padding: 0 5px;
  #         }
  #       '';
  #     };
  #   };
}
