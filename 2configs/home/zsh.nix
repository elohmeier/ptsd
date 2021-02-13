{ config, pkgs, ... }:
with import <ptsd/lib>;
let
  shellAliases = import ../aliases.nix;
in
{
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    z-lua = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      initExtra = ''
        if [ "$TERM" != dumb ]; then
          autoload -U colors && colors

          # green bold user name
          #PS1="%B%(?..[%?] )%b%(!.%{$fg_bold[red]%}%m.%{$fg_bold[green]%}%n@%m) %{$fg_bold[blue]%}%~%{$reset_color%} "

          # red bold user name
          #PS1="%B%(?..[%?] )%b%(!.%{$fg_bold[red]%}%m.%{$fg_bold[red]%}%n@%m) %{$fg_bold[red]%}%~%{$reset_color%} "

          # red regular user name
          PS1="%B%(?..[%?] )%b%(!.%{$fg[red]%}%m.%{$fg[red]%}%n@%m) %{$fg[red]%}%~%{$reset_color%} "

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

          # the following bindkey statments
          # fix the Ctrl-Left/Right keybindings
          # https://unix.stackexchange.com/questions/58870/ctrl-left-right-arrow-keys-issue/332049#332049

          # terminator, konsole and xterm (and maybe others):
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word

          # urxvt/rxvt-unicode (and maybe others)
          bindkey "^[Od" backward-word
          bindkey "^[Oc" forward-word
          bindkey "^[[1~" beginning-of-line
          bindkey "^[[4~" end-of-line

          booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
          built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

          if [ "$booted" != "$built" ]; then
            echo "please reboot"
          fi
        fi
      '';

      shellAliases = shellAliases;
    };
  };

  home.packages = [ pkgs.nix-zsh-completions ];
}
