{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    useBabelfish = true;

    shellAliases = {
      gapf = "git commit --amend --no-edit && git push --force";
      gaapf = "git add . && git commit --amend --no-edit && git push --force";
      grep = "grep --color";
      ping6 = "ping -6";
      telnet = "screen //telnet";
      vim = "nvim";
      vi = "nvim";
      l = "exa -al";
      la = "exa -al";
      lg = "exa -al --git";
      ll = "exa -l";
      ls = "exa";
      tree = "exa --tree";
    };

    shellAbbrs = {
      br = "broot";
      "cd.." = "cd ..";

      # git
      ga = "git add";
      "ga." = "git add .";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gs = "git status";
      gp = "git pull";
      gpp = "git push";
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
