{ config, pkgs, ... }:
with import <ptsd/lib>;

let
  shellAliases = import ../aliases.nix;
in
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.z-lua = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    initExtra = ''
      if [ "$TERM" != dumb ]; then
        autoload -U colors && colors

        #PS1="%B%(?..[%?] )%b%(!.%{$fg_bold[red]%}%m.%{$fg_bold[green]%}%n@%m) %{$fg_bold[blue]%}%~%{$reset_color%} "
        PS1="%B%(?..[%?] )%b%(!.%{$fg_bold[red]%}%m.%{$fg_bold[red]%}%n@%m) %{$fg_bold[red]%}%~%{$reset_color%} "

        function preexec() {
          timer=''${timer:-$SECONDS}
        }

        function precmd() {
          if [ $timer ]; then
            timer_show=$(($SECONDS - $timer))
            if [ $timer_show -lt 2 ]; then
              export RPROMPT=""
            else
              export RPROMPT="%F{cyan}''${timer_show}s %{$reset_color%}"
            fi
            unset timer
          fi
        }

        # allow any key to get things flowing again (after Ctrl-s)
        stty ixany

        # to disable Ctrl-s use this:
        # stty -ixon
      fi
    '';

    shellAliases = shellAliases;
  };

  home.packages = [ pkgs.nix-zsh-completions ];
}
