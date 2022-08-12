{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    useBabelfish = true;

    shellAliases = {
      gaapf = "git add . && git commit --amend --no-edit && git push --force";
      gapf = "git commit --amend --no-edit && git push --force";
      grep = "grep --color";
      l = "exa -al";
      la = "exa -al";
      lg = "exa -al --git";
      ll = "exa -l";
      ls = "exa";
      ping6 = "ping -6";
      telnet = "screen //telnet";
      tree = "exa --tree";
      vi = "nvim";
      vim = "nvim";
    };

    shellAbbrs = {
      "cd.." = "cd ..";
      br = "broot";

      # git
      "ga." = "git add .";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gp = "git pull";
      gpp = "git push";
      gs = "git status";
    };

    interactiveShellInit = ''
      set -U fish_greeting
    '' + lib.optionalString config.wayland.windowManager.sway.enable ''
      if status is-login
        if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
          # pass sway log output to journald
          exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --unsupported-gpu
        end
      end
    '';
  };

  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
