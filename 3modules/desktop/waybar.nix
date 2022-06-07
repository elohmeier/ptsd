{ nixosConfig, config, lib, pkgs, ... }:

with lib;

let
  cfg = nixosConfig.ptsd.desktop;
  secondarySettings = {
    layer = "top";
    position = "bottom";
    height = 33;
    modules-left = [
      "custom/add-workspace"
      "sway/workspaces"
      "sway/mode"
    ];
    modules = {
      "custom/add-workspace" = {
        format = "  ";
        on-click = toString pkgs.add-workspace;
      };
    };
  };
  primarySettings = {
    layer = "top";
    position = "bottom";
    height = 33;
    modules-left = secondarySettings.modules-left ++ [
      "custom/mediaplayer"
    ];
    modules-center = [
    ];
    modules-right = (optional cfg.autolock.enable "idle_inhibitor") ++ [
      #"custom/nobbofin-inbox"
    ] ++ (optional cfg.waybar.co2
      "custom/co2") ++ [
      "disk#home"
      "disk#sync"
      "disk#nix"
      "disk#xdg-runtime-dir"
    ]
      ++ optional cfg.audio.enable
      "pulseaudio" ++ [
      "network"
      "network#tun0"
      "cpu"
      "memory"
    ] ++ optional cfg.nvidia.enable "custom/nvidia" ++ [
      #"backlight"
      "battery"
      #"custom/mouse-battery"
      "clock"
      "tray"
    ];
    modules = secondarySettings.modules // {

      idle_inhibitor = mkIf cfg.autolock.enable {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      "custom/co2" = mkIf cfg.waybar.co2 {
        format = "co2 {}ppm";
        exec = "${pkgs.read-co2-status}/bin/read-co2-status";
        interval = 30;
        return-type = "json";
      };

      "custom/mediaplayer" = {
        format = " {}";
        escape = true;
        return-type = "json";
        max-length = 40;
        exec = "${pkgs.read-mediaplayer-status}/bin/read-mediaplayer-status";
      };

      # see also https://github.com/Alexays/Waybar/issues/975
      # "custom/mouse-battery" = {
      #   format = " {}";
      #   exec = "${pkgs.read-battery-status}/bin/read-battery-status";
      #   interval = 30;
      #   return-type = "json";
      #   on-click-right = cfg.term.execFloating "${pkgs.procps}/bin/watch -n1 ${pkgs.upower}/bin/upower -d" "";
      # };
      #"custom/nobbofin-inbox" = {
      #  format = "nbf {}";
      #  exec = pkgs.writeShellScript "nobbofin-inbox" ''
      #    ${pkgs.findutils}/bin/find /home/enno/repos/nobbofin/000_INBOX -type f | wc -l
      #  '';
      #  interval = 30;
      #};
      "disk#home" = rec {
        format = "ho {percentage_free}%";
        path = "/home";
        on-click-right = cfg.term.execFloating "${pkgs.ncdu}/bin/ncdu -x ${path}" "";
        states = {
          warning = 15;
          critical = 5;
        };
      };
      "disk#sync" = rec {
        format = "sy {percentage_free}%";
        path = "/sync";
        on-click-right = cfg.term.execFloating "${pkgs.ncdu}/bin/ncdu -x ${path}" "";
        states = {
          warning = 15;
          critical = 5;
        };
      };
      "disk#nix" = rec {
        format = "nix {percentage_free}%";
        path = "/nix";
        states = {
          warning = 15;
          critical = 5;
        };
      };
      "disk#xdg-runtime-dir" = rec {
        format = "xrd {percentage_free}%";
        path = "/run/user/1000";
        on-click-right = cfg.term.execFloating "${pkgs.ncdu}/bin/ncdu -x ${path}" "";
        states = {
          warning = 15;
          critical = 5;
        };
      };
      cpu = {
        format = "{usage}% ";
        on-click-right = cfg.term.execFloating "${pkgs.btop}/bin/btop" "";
      };
      memory = {
        format = "{}% ";
        on-click-right = cfg.term.execFloating "${pkgs.procps}/bin/watch -n1 ${pkgs.coreutils}/bin/cat /proc/meminfo" "";
      };
      #"custom/nvidia" = mkIf cfg.nvidia.enable {
      #  format = "nv {}";
      #  exec = pkgs.writeNu "nv-status" ''
      #    nvidia-smi --query-gpu=pstate,utilization.gpu,utilization.memory,temperature.gpu --format=csv,nounits | from csv | str trim  | each { echo $"($it.pstate) ($it.' utilization.gpu [%]')%C ($it.' utilization.memory [%]')%M ($it.' temperature.gpu')C" }
      #  '';
      #  interval = 30;
      #};
      battery = {
        states = { warning = 30; critical = 15; };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        format-icons = [ "" "" "" "" "" ];
      };
      clock = {
        format = "{:%a, %d. %b  %H:%M}";
        on-click-right = cfg.term.execFloating "bash -c 'cal -w -y && echo press enter to exit && read'" "";
      };
      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        on-click-right = mkIf nixosConfig.networking.networkmanager.enable (cfg.term.execFloating "${pkgs.networkmanager}/bin/nmtui" "");
      };
      "network#tun0" = {
        interface = "tun0";
        format = "{ifname} {ipaddr}";
      };
      pulseaudio = mkIf cfg.audio.enable {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" "" ];
        };
        on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
    };
  };
in
{
  programs.waybar = mkIf (!cfg.i3compat) {
    enable = true;
    settings =
      if cfg.waybar.primaryOutput == "" then [
        primarySettings
      ]
      else [
        (primarySettings // { output = cfg.waybar.primaryOutput; })
        (secondarySettings // { output = "!${cfg.waybar.primaryOutput}"; })
      ];
    style =
      ''
        * {
            border: none;
            border-radius: 0;
            font-family: ${cfg.fontSans};
            font-size: ${toString cfg.fontSize}pt;
            min-height: 0;
        }

        window#waybar {
            background-color: ${cfg.waybar.bgColor};
            color: ${cfg.waybar.fgColor};
            transition-property: background-color;
            transition-duration: .5s;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }
              
        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: ${cfg.waybar.fgColor};
            border-bottom: 3px solid transparent;
        }

        #workspaces button.focused {
            background-color: ${cfg.waybar.contrastColor};
            border-bottom: 1px solid ${cfg.waybar.accentColor};
        }

        #workspaces button.urgent {
            background-color: ${cfg.waybar.accentColor};
        }

        #mode {
            background-color: ${cfg.waybar.bgColor};
            border-bottom: 1px solid #dc322f;
        }

        #clock, #battery, #cpu, #memory, #backlight, #network, #pulseaudio, #tray, #mode, #idle_inhibitor, #disk, #custom-co2, #custom-mouse-battery, custom-add-workspace {
            padding: 0 10px;
            margin: 0 2px;
            background-color: ${cfg.waybar.bgColor};
            color: ${cfg.waybar.fgColor};
        }
                
        #battery.charging {
            color: #eee8d5;
            background-color: #859900;
        }

        @keyframes blink {
            to {
                background-color: #d33682;
                color: #93a1a1;
            }
        }

        #custom-co2.alert, #custom-mouse-battery.alert {
          background-color: #dc322f;
          color: #ffffff;
        }

        #battery.critical:not(.charging) {
            background-color: #dc322f;
            color: #93a1a1;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        label:focus {
            background-color: ${cfg.waybar.contrastColor};
        }

        #pulseaudio.muted {
            background-color: ${cfg.waybar.contrastColor};
        }

        #idle_inhibitor.activated {
            background-color: ${cfg.waybar.contrastColor};
        }

      '';
  };

}
