{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {

      font.normal.family = if pkgs.stdenv.isDarwin then "SauceCodePro Nerd Font" else "Spleen";
      font.size = lib.mkIf pkgs.stdenv.isLinux 18.0;

      key_bindings =
        lib.optionals pkgs.stdenv.isDarwin [
          { key = 28; mods = "Alt"; chars = "{"; }
          { key = 25; mods = "Alt"; chars = "}"; }
          { key = 37; mods = "Alt"; chars = "@"; }
          { key = 26; mods = "Alt|Shift"; chars = "\\\\"; }
          { key = 26; mods = "Alt"; chars = "|"; }
          { key = 45; mods = "Alt"; chars = "~"; }
          { key = 23; mods = "Alt"; chars = "["; }
          { key = 22; mods = "Alt"; chars = "]"; }
        ];
    };
  };

}
