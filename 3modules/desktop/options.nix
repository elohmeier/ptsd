{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.ptsd.desktop;
in
{
  options = {
    ptsd.desktop = {
      enable = mkEnableOption "ptsd.desktop";
      fontSans = mkOption {
        type = types.str;
        default = "Ioseka Sans"; # TODO: expose package, e.g. for gtk
      };
      fontMono = mkOption {
        type = types.str;
        default = "Consolas";
      };
      fontSize = mkOption {
        type = types.float;
        default = 10.0;
      };
      primaryMicrophone = mkOption {
        type = with types; nullOr str;
        description = "Pulseaudio microphone device name";
        default = "@DEFAULT_SOURCE@";
      };
      primarySpeaker = mkOption {
        type = with types; nullOr str;
        description = "Pulseaudio speaker device name";
        default = "@DEFAULT_SINK@";
      };
      themeConfig = mkOption {
        type = types.str;
        default = "dark";
      };
      trayOutput = mkOption {
        type = types.str;
        default = "primary";
        description = "Where to output tray.";
      };
      modifier = mkOption {
        type = types.str;
        default = "Mod4";
      };
      lockImage = mkOption {
        type = types.str;
        default = "";
      };
      hideCursorIdleSec = mkOption {
        type = types.int;
        default = 1;
      };
      bemenuArgs = mkOption { type = types.str; default = ""; };
      waybar.co2 = mkOption {
        type = types.bool;
        default = false;
      };
      waybar.bgColor = mkOption { type = types.str; default = "#ffffff"; };
      waybar.fgColor = mkOption { type = types.str; default = "#000000"; };
      waybar.contrastColor = mkOption { type = types.str; default = "#111111"; };
      waybar.accentColor = mkOption { type = types.str; default = "#1a1a1a"; };
      audio.enable = mkOption {
        type = types.bool;
        default = true;
      };
      nvidia.enable = mkOption { type = types.bool; default = false; };
      bluetooth.enable = mkOption {
        type = types.bool;
        default = true;
      };
      qt.enable = mkOption {
        type = types.bool;
        default = true;
      };
      numlockAuto = mkOption {
        type = types.bool;
        default = true;
      };
      defaultBrowser = mkOption {
        type = types.str;
        default = "choose-browser.desktop";
      };
      autolock.enable = mkOption {
        type = types.bool;
        default = true;
      };
      rclone.enable = mkOption {
        type = types.bool;
        default = false;
      };
      baresip = mkOption {
        default = { };
        type = types.submodule {
          options = {
            enable = mkEnableOption "baresip";
            audioPlayer = mkOption { type = types.str; default = ""; };
            audioSource = mkOption { type = types.str; default = ""; };
            audioAlert = mkOption { type = types.str; default = ""; };
            sipListen = mkOption { type = types.str; default = ""; example = "10.0.0.2:5060"; };
            netInterface = mkOption { type = types.str; default = ""; example = "nwvpn"; };
          };
        };
      };
      lockCmd = mkOption {
        default = if cfg.lockImage != "" then ''${pkgs.swaylock}/bin/swaylock --image "${cfg.lockImage}" --scaling center --color 000000 -f'' else "${pkgs.swaylock}/bin/swaylock --color 000000 -f";
      };
      cwdCmd = mkOption {
        default = "${pkgs.swaycwd}/bin/swaycwd";
      };
      exit_mode = mkOption {
        default = "exit: [l]ogout, [r]eboot, reboot-[w]indows, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";
      };
      term = mkOption {
        default = { };
        type = types.submodule {
          options = {
            package = mkOption {
              type = types.package;
              default = pkgs.foot;
            };
            binary = mkOption {
              default = "${cfg.term.package}/bin/footclient"; # requires foot-server.service
              type = types.str;
            };
            exec = mkOption {
              default = prog: dir: "${cfg.term.binary}${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
              type = types.functionTo (types.functionTo types.str);
            };
            execFloating = mkOption {
              default = prog: dir: "${cfg.term.binary} --app-id=term.floating${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
              type = types.functionTo (types.functionTo types.str);
            };
          };
        };
      };
    };
  };
}
