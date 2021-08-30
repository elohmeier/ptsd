{ pkgs, ... }:

{
  imports = [
    ../../2configs/fish.nix
  ];

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      foot
      bemenu
    ];
  };

  # initrd shouldn't get too large...
  # environment.systemPackages = with pkgs; [
  #   firefox
  #   glxinfo
  # ];

  users.users.enno.shell = pkgs.fish;

  fonts.fonts = with pkgs; [ source-code-pro ];



  home-manager.users.enno = { config, nixosConfig, pkgs, ... }:
    {
      imports = [
        ../../2configs/home/fish.nix
      ];

      wayland.windowManager.sway = {
        enable = true;
        config = {
          bars = [{
            command = "${pkgs.waybar}/bin/waybar";
          }];

          input = {
            "*" = {
              xkb_layout = "de";
            };

            raspberrypi-ts = {
              map_to_output = "DSI-1";
            };
          };
          menu = "${pkgs.bemenu}/bin/bemenu-run --fn 'Source Code Pro'";
          modifier = "Mod4";
          terminal = "${pkgs.foot}/bin/footclient";
        };
      };

      programs.foot = {
        enable = true;
        server.enable = true;
        settings = {
          main = {
            font = "Source Code Pro:size=11";
            dpi-aware = "yes";
          };
        };
      };

      programs.waybar = {
        enable = true;
        settings = [{
          layer = "top";
          position = "top";
          height = 50;
          output = [ "DSI-1" ];
          modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
          modules-center = [ "sway/window" ];
          modules-right = [ "temperature" ];
          modules = {
            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };
          };
        }];
        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: Source Code Pro;
            }
          window#waybar {
            background: #16191C;
            color: #AAB2BF;
          }
          #workspaces button {
            padding: 0 5px;
          }
        '';
      };

      home.stateVersion = "21.05";
    };
}
